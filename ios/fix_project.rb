require 'xcodeproj'

project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first # Runner target

file_name = 'GoogleService-Info.plist'
file_path = "Runner/#{file_name}"

# Check if file is already in the project
existing_file = target.resources_build_phase.files_references.find { |file| file.path == file_name }

if existing_file
  puts "#{file_name} is already in the project."
else
  puts "Adding #{file_name} to the project..."
  
  # Add file to the 'Runner' group
  group = project.main_group.find_subpath(File.join('Runner'), true)
  file_ref = group.new_reference(file_name)
  
  # Add file to the target's resources build phase
  target.resources_build_phase.add_file_reference(file_ref)
  
  project.save
  puts "Successfully added #{file_name} to the project."
end
