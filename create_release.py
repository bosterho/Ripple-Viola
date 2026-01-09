#!/usr/bin/env python3
"""
Release Creation Script
Automates the process of creating a release and uploading to Dropbox
"""

import os
import sys
import shutil
import subprocess
import json
import platform
from pathlib import Path

# ============================================================
# CONFIGURATION - Loaded from release_config.json
# ============================================================

def load_config():
    """Load configuration from JSON file"""
    config_file = Path(__file__).parent / "release_config.json"

    if not config_file.exists():
        print_error(f"Configuration file not found: {config_file}")
        print_info("Please create release_config.json in the same directory as this script.")
        input("\nPress Enter to close...")
        sys.exit(1)

    with open(config_file, 'r') as f:
        return json.load(f)

def save_config(config):
    """Save configuration to JSON file"""
    config_file = Path(__file__).parent / "release_config.json"
    with open(config_file, 'w') as f:
        json.dump(config, f, indent=2)

def increment_version(version_str):
    """Increment the patch version number (0.9.2 -> 0.9.3)"""
    parts = version_str.split('.')
    if len(parts) == 3:
        major, minor, patch = parts
        return f"{major}.{minor}.{int(patch) + 1}"
    return version_str

# ============================================================

# Simple output functions (no colors for universal compatibility)
def print_info(msg):
    print(msg)

def print_success(msg):
    print(msg)

def print_error(msg):
    print(f"ERROR: {msg}")

def print_warning(msg):
    print(f"WARNING: {msg}")

def print_header(msg):
    print(f"\n{msg}")

def get_user_choice(prompt, options):
    """Display a menu and get user choice"""
    print_header(prompt)
    for i, option in enumerate(options, 1):
        print(f"  {i}. {option}")

    while True:
        try:
            choice = input(f"\nEnter choice (1-{len(options)}): ").strip()
            choice_num = int(choice)
            if 1 <= choice_num <= len(options):
                return choice_num - 1  # Return 0-based index
            else:
                print_error(f"Please enter a number between 1 and {len(options)}")
        except ValueError:
            print_error("Please enter a valid number")
        except KeyboardInterrupt:
            print_error("\n\nCancelled by user")
            sys.exit(1)

def get_yes_no(prompt, default=True):
    """Get yes/no response from user"""
    default_str = "Y/n" if default else "y/N"
    while True:
        response = input(f"{prompt} ({default_str}): ").strip().lower()
        if response == '':
            return default
        if response in ['y', 'yes']:
            return True
        if response in ['n', 'no']:
            return False
        print_error("Please enter 'y' or 'n'")

def get_directory_size(path):
    """Calculate total size of directory in bytes"""
    total = 0
    for entry in os.scandir(path):
        if entry.is_file():
            total += entry.stat().st_size
        elif entry.is_dir():
            total += get_directory_size(entry.path)
    return total

def format_size(bytes):
    """Format bytes to human readable size"""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if bytes < 1024.0:
            return f"{bytes:.2f} {unit}"
        bytes /= 1024.0
    return f"{bytes:.2f} TB"

def should_exclude_path(relative_path, exclude_patterns):
    """Check if a path matches any exclusion pattern"""
    path_str = str(relative_path).replace('\\', '/')
    for pattern in exclude_patterns:
        pattern_normalized = pattern.replace('\\', '/')
        if path_str == pattern_normalized or path_str.startswith(pattern_normalized + '/'):
            return True
    return False

def find_winrar():
    """Find WinRAR executable on the system"""
    if platform.system() == "Windows":
        # Common WinRAR installation paths on Windows
        possible_paths = [
            r"C:\Program Files\WinRAR\WinRAR.exe",
            r"C:\Program Files (x86)\WinRAR\WinRAR.exe",
        ]
        for path in possible_paths:
            if Path(path).exists():
                return path
    else:
        # On Mac, check for rar command (from homebrew: brew install rar)
        try:
            result = subprocess.run(['which', 'rar'], capture_output=True, text=True)
            if result.returncode == 0:
                return 'rar'
        except:
            pass
    return None

def create_rar_archive(source_folder, output_path):
    """Create a RAR archive using WinRAR"""
    winrar_exe = find_winrar()

    if not winrar_exe:
        return None

    print_info(f"Creating RAR archive using WinRAR...")

    try:
        cmd = [
            winrar_exe,
            'a',           # Add to archive
            '-m3',         # Normal compression (balanced)
            '-r',          # Recurse subdirectories
            '-ep1',        # Exclude base folder from paths
            str(output_path),
            str(source_folder) + '\\*'
        ]

        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode == 0:
            return output_path
        else:
            print_error(f"WinRAR compression failed with error code {result.returncode}")
            if result.stderr:
                print_error(f"Error details: {result.stderr}")
            return None
    except Exception as e:
        print_error(f"Error running WinRAR: {e}")
        return None

def main():
    # Load configuration
    config = load_config()

    # Auto-detect project name from parent folder
    PROJECT_NAME = Path.cwd().parent.name

    LAST_VERSION = config.get('last_version', '0.0.0')
    DROPBOX_PATH = config.get('dropbox_path', '')
    FOLDERS_TO_INCLUDE = config['folders_to_include']
    FILES_TO_INCLUDE = config.get('files_to_include', [])
    FOLDERS_TO_EXCLUDE = config.get('folders_to_exclude', [])

    print_header(f"{PROJECT_NAME} Release Creator")
    print_info("=" * 60)

    # Get version number
    suggested_version = increment_version(LAST_VERSION)

    version_input = input(f"Version number (press Enter for {suggested_version}): ").strip()

    if version_input:
        version = version_input
    else:
        version = suggested_version

    print_success(f"Using version: {version}")

    # Get description
    print_header("Release Description")
    description = input("Enter a short description: ").strip()

    # Use configured Dropbox path
    dropbox_path = DROPBOX_PATH

    # Build release name
    release_name = f"v{version}"
    if description:
        release_name += f" - {description}"

    print_info("=" * 60)
    print_success(f"Creating release: {PROJECT_NAME} {release_name}")
    print_info("=" * 60)

    # Paths
    base_dir = Path.cwd()
    beta_folder = base_dir.parent / "Beta"
    release_folder = beta_folder / f"{PROJECT_NAME} {release_name}"

    # Create Beta folder if it doesn't exist
    beta_folder.mkdir(parents=True, exist_ok=True)

    # Remove old release folder if it exists
    if release_folder.exists():
        print_info("Removing old release folder...")
        shutil.rmtree(release_folder)

    # Create release directory
    release_folder.mkdir(parents=True, exist_ok=True)

    # Copy individual files based on configuration
    for file in FILES_TO_INCLUDE:
        print_info(f"Copying {file}...")
        source_file = base_dir / file
        if source_file.exists():
            shutil.copy2(source_file, release_folder / file)
            print(f"  + {file} copied")
        else:
            print_warning(f"  ! {file} not found")

    # Copy folders based on configuration
    for folder in FOLDERS_TO_INCLUDE:
        print_info(f"Copying {folder}/...")
        source_dir = base_dir / folder
        if source_dir.exists():
            # Use ignore function to exclude specified folders
            def ignore_excluded(dir, files):
                ignored = []
                for name in files:
                    item_path = Path(dir).relative_to(base_dir) / name
                    if should_exclude_path(item_path, FOLDERS_TO_EXCLUDE):
                        ignored.append(name)
                        print(f"  Skipping {item_path}/ (excluded)")
                return ignored

            shutil.copytree(source_dir, release_folder / folder, ignore=ignore_excluded)
            print(f"  + {folder}/ folder copied")
        else:
            print_warning(f"  ! {folder}/ not found")

    if FOLDERS_TO_EXCLUDE:
        print_info(f"Excluded folders: {', '.join(FOLDERS_TO_EXCLUDE)}")

    # Calculate total size before compressing
    total_size = get_directory_size(release_folder)
    print_info(f"\nTotal content size: {format_size(total_size)}")

    # Create RAR archive
    archive_filename = f"{PROJECT_NAME} {release_name}.rar"
    archive_path = beta_folder / archive_filename

    if archive_path.exists():
        archive_path.unlink()

    archive_path = create_rar_archive(release_folder, archive_path)

    if not archive_path:
        print_error("WinRAR is required but not found.")
        print_info("Please install WinRAR and try again.")
        input("\nPress Enter to close...")
        sys.exit(1)

    # Get final archive size
    archive_size = archive_path.stat().st_size
    compression_ratio = (1 - archive_size / total_size) * 100 if total_size > 0 else 0
    archive_type = "RAR" if archive_filename.endswith('.rar') else "ZIP"
    print_success(f"+ {archive_type} created: {format_size(archive_size)} (compressed {compression_ratio:.1f}%)")

    # Move archive to Dropbox
    if dropbox_path:
        dropbox_dest = Path(dropbox_path)
        if dropbox_dest.exists():
            print_info("\nMoving to Dropbox...")
            dropbox_dest.mkdir(parents=True, exist_ok=True)
            dropbox_file = dropbox_dest / archive_filename
            shutil.move(str(archive_path), str(dropbox_file))
            print_success(f"+ Moved to Dropbox: {dropbox_file}")
        else:
            print_error(f"Dropbox path not found: {dropbox_dest}")
            print_info(f"Archive file remains at: {archive_path}")
    else:
        print_warning("\nNo Dropbox path specified")
        print_info(f"Archive file saved at: {archive_path}")

    # Save the version to config for next time
    config['last_version'] = version
    save_config(config)

    # Summary
    print()
    print_success("=" * 60)
    print_success("Release creation complete!")
    print_success("=" * 60)
    print()
    print_info(f"Release folder: {release_folder}")
    if dropbox_path and Path(dropbox_path).exists():
        print_info(f"Archive moved to Dropbox: {Path(dropbox_path) / archive_filename}")
    else:
        print_info(f"Archive file: {archive_path}")
    print_info(f"Version {version} saved as last version")
    print()

    # Keep window open
    input("Press Enter to close...")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print_error("\n\nCancelled by user")
        sys.exit(1)
    except Exception as e:
        print_error(f"\nError: {e}")
        sys.exit(1)
