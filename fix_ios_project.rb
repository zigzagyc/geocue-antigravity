require 'xcodeproj'

project_path = 'ios/Runner.xcodeproj'
file_name = 'GoogleService-Info.plist'

begin
  puts "Opening project at #{project_path}..."
  project = Xcodeproj::Project.open(project_path)
  
  # Find the Runner target
  target = project.targets.find { |t| t.name == 'Runner' }
  unless target
    puts "Error: Runner target not found."
    exit 1
  end

  # Find the Runner group (where Info.plist usually is)
  group = project.main_group['Runner']
  unless group
    puts "Error: Runner group not found."
    exit 1
  end

  # Check if file is already in group
  if group.find_file_by_path(file_name)
    puts "#{file_name} reference already exists in group."
  else
    puts "Adding #{file_name} reference to group..."
    file_ref = group.new_reference(file_name) # This adds it to the group
    
    # Add to Copy Bundle Resources phase
    puts "Adding to Copy Bundle Resources build phase..."
    target.add_resources([file_ref])
    
    project.save
    puts "Project saved successfully."
  end

rescue LoadError
  puts "Error: xcodeproj gem not found. Please install it or use 'pod install'."
  exit 1
rescue => e
  puts "An error occurred: #{e.message}"
  puts e.backtrace
  exit 1
end
