require 'find'

def copy_all_but_fixtures(source_path, target_path)
puts source_path
      puts target_path
  skip_directories = [
      File.join('.tmp'),
      File.join('.librarian'),
      File.join('.vagrant'),
      File.join('.git'),
      File.join('builds'),
      File.join('common'),
      File.join('spec', 'fixtures'),
      File.join('packer_cache'),
  ]

  Find.find(source_path) do |source|
    target = source.sub(/^#{source_path}/, target_path)
    if File.directory? source
      Find.prune if skip_directories.any? { |f| source.end_with? f }
      FileUtils.mkdir target unless File.exists? target
    else
      FileUtils.copy source, target
      puts source
      puts target
    end
  end
end

def module_name
  ENV.fetch('MODULE_NAME', File.basename(Dir.pwd).sub(/^puppet-/, ''))
end

def fixtures_path
  ENV.fetch('FIXTURES_PATH', File.join('spec', 'fixtures'))
end

# Install modules using librarian to specified path
def librarian_set_tmp_directory(tmp_path)
  command = ['librarian-puppet', 'config', 'tmp', tmp_path, '--global']
  command << '--verbose' unless ENV['LIBRARIAN_VERBOSE'].nil?
  sh *command
end

def is_running_on_windows?
  require 'rbconfig'
  is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
end

# Install modules using librarian to specified path
def librarian_prepare_modules (module_path)
  rm_rf module_path
  mkdir_p module_path
  #command = ['librarian-puppet', 'install', '--clean']
  command = ['librarian-puppet', 'install', '--no-use-v1-api']
  command << '--verbose' unless ENV['LIBRARIAN_VERBOSE'].nil?
  command.concat(['--path', module_path])
  sh *command
end

# Prepare manifest as entry point for testing.
def prepare_manifest_tests (manifest_path, manifest_file)
  # copy test manifest which includes current module
  rm_rf manifest_path
  mkdir_p manifest_path
  cp manifest_file, manifest_path
end

# Copy current module into fixtures folder for testing
def copy_module (path, name)
  module_path = File.join(path, name)
  puts module_path
  mkdir_p module_path
  copy_all_but_fixtures('.', module_path)
end

def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable? exe
    }
  end
  return nil
end

def vmware_vdiskmanager_path
  if (/darwin/ =~ RUBY_PLATFORM) != nil
    '/Applications/VMware Fusion.app/Contents/Library/vmware-vdiskmanager'
  else
    which('vmware-vdiskmanager')
  end
end

def external_vmdks_json_path
  File.join('builds', 'external_vmdks.json')
end

def packer_hash
  require 'json'
  json_file = File.read(generated_packer_template)
  hash      = JSON.parse(json_file)
end

def packer_vmware_iso_builder
  hash    = packer_hash
  builder = hash['builders'].find { |b| b['type'] == 'vmware-iso' }
end

def packer_vmware_vmx_builder
  hash    = packer_hash
  builder = hash['builders'].find { |b| b['type'] == 'vmware-vmx' }
end

class ERBContext
  def initialize(hash)
    hash.each_pair do |key, value|
      instance_variable_set('@' + key.to_s, value)
    end
  end
  def get_binding
    binding
  end
end

def render_all_erbs_to(temp_dir, key_values={})
  require 'erb'
  binding = ERBContext.new(key_values).get_binding
  should_flush_to_disk = false
  hash  = packer_hash
  builders_with_floppies = hash['builders'].find_all { |b| b.has_key?('floppy_files') }
  builders_with_floppies.each do |b|
    floppy_files = b['floppy_files']
    erbs = floppy_files.find_all { |f| f.end_with?('.erb') }
    files = erbs.collect { |e|
      temp_file = create_temp_file_from_erb(e, binding, temp_dir)
      floppy_files.delete(e)
      floppy_files << temp_file
      should_flush_to_disk = true
    }
  end

  builders_with_user_data_files = hash['builders'].find_all { |b| b.has_key?('user_data_file') }
  builders = (ENV['PACKER_BUILDERS'] || '').split(',')
  builders_with_user_data_files.each do |b|
    user_data_file = b['user_data_file']
    if user_data_file.end_with?('.erb') && builders.include?('amazon-ebs')
      abort "ENV[SSH_AUTHORIZED_KEYS] is required for user_data_file" if ENV['SSH_AUTHORIZED_KEYS'].nil?
      temp_file = create_temp_file_from_erb(user_data_file, binding, temp_dir)
      b['user_data_file'] = temp_file
      should_flush_to_disk = true
    end
  end
  if should_flush_to_disk
    File.open(generated_packer_template, 'wb') { |f| f.write(JSON.pretty_generate(JSON.parse(hash.to_json))) }
  end
end

def create_temp_file_from_erb(e, binding, temp_dir)
  input = File.open(e, "rb").read
  renderer = ERB.new(input)     
  output = renderer.result(binding)
  temp_file = File.join(temp_dir, File.basename(e).chomp('.erb'))
  File.open(temp_file, 'wb') { |f| f.write(output) }
  temp_file
end

def has_second_drive_configuration?
  builders = (ENV['PACKER_BUILDERS'] || '').split(',')
  return false if !builders.empty? and !builders.include?('vmware-iso')

  builder = packer_vmware_iso_builder
  return false if builder.nil?
  return false unless builder.has_key?('vmx_data')
  builder['vmx_data'].has_key?('scsi0:1.filename')
end

def second_drive_size
  builder  = packer_vmware_iso_builder || {}

  # NOTE: The size property here is fake (note the # comment). We're using this to determine
  #       what size of vmdk to create
  size_key = '#scsi0:1.size'
  size     = (builder['vmx_data'] || {})[size_key] || 0
  size.to_i
end

def create_vmdk(vmdk_file, size)
  unless File.exists?(vmdk_file)
    output_directory = File.dirname(vmdk_file)
    mkdir_p output_directory unless File.exists?(output_directory)
    puts "*** NOTE!!! Creating '#{vmdk_file}' for 'data' drive with size '#{size}'. (Currently done outside of Packer)"

    #     -c                   : create disk.  Additional creation options must
    #                            be specified.  Only local virtual disks can be
    #                            created.
    #     -s <size>            : capacity of the virtual disk
    #     -a <adapter>         : (for use with -c only) adapter type
    #                            (ide, buslogic, lsilogic). Pass lsilogic for other adapter types.
    #     -t <disk-type>       : disk type id
    #
    #  Disk types:
    #      0                   : single growable virtual disk
    #      1                   : growable virtual disk split in 2GB files
    #      2                   : preallocated virtual disk
    #      3                   : preallocated virtual disk split in 2GB files
    #      4                   : preallocated ESX-type virtual disk
    #                            NOTE: VMware Virtual Disk Manager can only convert to ESX thin disks if the destination is remote.
    #      5                   : compressed disk optimized for streaming
    #      6                   : thin provisioned virtual disk - ESX 3.x and above

    command = [
        vmware_vdiskmanager_path,
        '-c',
        '-s', size,
        '-a', 'lsilogic',
        '-t', '1',
        vmdk_file
    ]
    sh *command
  end
end

def create_vmdk_json(external_vmdks_path, build_dir)
  json = { :external_vmdks => Dir["#{external_vmdks_path}/*"].join(',') }.to_json
  File.open(external_vmdks_json_path, 'wb') { |f| f.write(json) }
end

def move_data_drive_into_output_directory(external_vmdks_path, output_directory)
  Dir.glob(File.join(external_vmdks_path, '*')).each do |file|
    FileUtils.mv file, File.join(output_directory, File.basename(file))
  end
end

def update_vmx_in_output_directory(vmx_file)
  text  = File.read(vmx_file)
  regex = Regexp.quote('../external_vmdks/')
  text.gsub!(/#{regex}/, '')
  File.open(vmx_file, 'wb') { |file| file.write(text) }
end

def untar_vagrant_box_with(untarred_vagrant_box_directory , box_file_path)
  Dir.mkdir(untarred_vagrant_box_directory)
  command = [
      'tar',
      'xvf',
      box_file_path,
      '-C',
      untarred_vagrant_box_directory,
  ]
  sh *command
end

def tar_vagrant_box_with(untarred_vagrant_box_directory, box_file_path)
  command = [
      'tar',
      'cvf',
      box_file_path,
      '-C',
      untarred_vagrant_box_directory,
      '.',
  ]
  sh *command
  FileUtils.remove_dir(untarred_vagrant_box_directory)
end

def copy_vmx_in_output_directory_to_untarred_vagrant_box_directory(vmx_file, untarred_vagrant_box_directory)
  FileUtils.cp(vmx_file, untarred_vagrant_box_directory)
end

def compress_vagrant_box(box_file_path, compression)
  unless compression == '0'
    command = [
        'gzip',
        "-#{compression}",
        box_file_path
    ]
    sh *command
    FileUtils.mv "#{box_file_path}.gz", box_file_path
  end
end

def enhanced_packer_template
  'packer.json'
end

def generated_packer_template
  'packer.local'
end

def packer_template_file
  if File.exists?(enhanced_packer_template) && File.exists?(generated_packer_template)
    generated_packer_template
  else
    enhanced_packer_template
  end
end

def generate_packer_template
  minify_json(enhanced_packer_template, generated_packer_template)
end

def minify_json(source, target)
  if File.exists?(source)
    require 'json'
    require 'json/minify'
    minified   = JSON.minify(File.open(source, 'rb').read)
    prettyfied = JSON.pretty_generate(JSON.parse(minified))
    File.open(target, 'wb') { |f| f.write(prettyfied) }
    raise "Generated json (#{target}) was not created from #{source}" unless File.exists?(target)
  end
end
