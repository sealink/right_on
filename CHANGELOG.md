# Change Log
All notable changes to this project will be documented in this file.  
This project adheres to [Semantic Versioning](http://semver.org/).  
This changelog adheres to [Keep a CHANGELOG](http://keepachangelog.com/).  

## 0.4.1

- [TT-4960] ByGroup will now return a hash sorted by role name

## 0.4.0

### Improved
- Improve tests for RightOn::ByGroup
- Internal improvement of RightOn::ByGroup
- Internal extraction of 'allowed?' feature for failure message
- CanCanRight functionality merged into RightOn
- Cleanup of CanCanRight/RightOn merge

### Fixed
- [TT-3352] Ensure roles currently in use cannot be deleted
- Also dropped rails 3 support due to above

## 0.3.0

### Fixed
- Caching of rights in memory (causing tenant issues)

### Removed
- restricted_by_right no longer supported

## 0.2.0

### Added
- Rails 4/5 support
- Groupless rights

### Added
- [TT-1392] Changelog file
