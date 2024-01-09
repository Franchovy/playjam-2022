
import os
import sys
import re

# Define the input-output library mapping dictionary
library_mapping = {
    "graphics": "gfx",
    "sound": "sound",
    "file": "file",
    "display": "disp",
    "geometry": "geo",
    "timer": "timer",
    "easingFunctions": "easing"
}

def extract_libraries(file_content):
    # Regex pattern to match "playdate.xxx" format
    pattern = r"playdate\.(\w+)(?:[.\s]|$)"
    matches = re.findall(pattern, file_content)
    # Filter and map input libraries list to output library names
    libraries = [lib for lib in list(set(matches)) if lib in library_mapping]
    print("Libraries matched:", libraries)
    return libraries

def modify_file(file_path, libraries):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
        
        # Replace every occurrence of "playdate.[library]" with "[library]"
        for lib in libraries:
            print(f"lib: {lib}")
            pattern = r"playdate\." + lib + r"(?![\w])"
            content = re.sub(pattern, library_mapping.get(lib, lib), content)
        
        # Create strings to insert
        last_import_index = content.rfind("import")
        last_import_line_index = content.find("\n", last_import_index) + 1 if last_import_index != -1 else 0
        inserts = [f"local {library_mapping.get(lib, lib)} <const> = playdate.{lib}\n" for lib in libraries]
        
        if last_import_line_index > 0:
            inserts.insert(0, "\n")
        
        insert_string = ''.join(inserts)
        
        # Modify the file content
        modified_content = content[:last_import_line_index] + insert_string + content[last_import_line_index:]
        
        # Write modified content back to the file
        with open(file_path, 'w', encoding='utf-8') as file:
            file.write(modified_content)
        
        print("File modified successfully")
        
    except UnicodeDecodeError:
        print(f"Cannot read file: {file_path} (UnicodeDecodeError)")
    except Exception as e:
        print(f"Error modifying file: {file_path}")
        print(e)

def parse_directory(path):
    if os.path.isfile(path) and path.endswith('.lua'):
        try:
            with open(path, 'r', encoding='utf-8') as f:
                file_content = f.read()
                libraries = extract_libraries(file_content)
                
                if len(libraries) > 0:
                    modify_file(path, libraries)
                else:
                    print("No or only one library found. Skipping modification.")
        except Exception as e:
            print(f"Error processing file: {path}")
            print(e)
    elif os.path.isdir(path):
        if not os.path.exists(path):
            print("Directory doesn't exist.")
            return
        
        for root, dirs, files in os.walk(path):
            print(f"Current directory: {root}")
            
            for file in files:
                if file.endswith('.lua'):
                    file_path = os.path.join(root, file)
                    try:
                        with open(file_path, 'r', encoding='utf-8') as f:
                            file_content = f.read()
                            libraries = extract_libraries(file_content)
                            
                            if len(libraries) > 0:
                                modify_file(file_path, libraries)
                            else:
                                print("No or only one library found. Skipping modification.")
                    except Exception as e:
                        print(f"Error processing file: {file_path}")
                        print(e)
    else:
        print("Invalid file or directory.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script_name.py <directory_name or file_name.lua>")
    else:
        path = sys.argv[1]
        parse_directory(path)