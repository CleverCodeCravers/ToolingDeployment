# ToolingDeployment

## For windows

Script to download releases and create an up-to-date tooling directory

The script is called this way:

```powershell
Update-To-Latest-Versions.ps1 -TargetDirectory C:\Tools
```

1. If the target directory does not exist, it will create the directory.
2. It looks through all repositories that are hosted in repositories by the CleverCodeCravers.
3. For every repository it finds it will:
  - Fetch information about the last release
  - If the release is older/different from the one present in the target directory or the tool is not downloaded yet, it will 
    - download the zip files that match the operating system (`win-x64`)
    - extract the content
    - and copy only the exe file to the target directory (just in case there are any pdb files present - we do not want those)
    - update a json file in which it remembers the version, the zip file, and what exe files belong to it
    
The result is a clean tools directory with a json-File that acts as storage for all current release information as well as all up to date exe-versions of our tools. 

## For linux

Script to download releases and create an up-to-date tooling directory

The script is called this way:

```python
python3 Update-To-Latest-Versions.py -TargetDirectory ./Tools
```

1. If the target directory does not exist, it will create the directory.
2. It looks through all repositories that are hosted in repositories by the CleverCodeCravers.
3. For every repository it finds it will:
  - Fetch information about the last release
  - If the release is older/different from the one present in the target directory or the tool is not downloaded yet, it will 
    - download the zip files that match the operating system (`linux-x64`)
    - extract the content
    - and copy only the executable file to the target directory (just in case there are any pdb files present - we do not want those) (the executable files 
      - hint: if the file is executable or not can be found out using the file-tool under linux. Since linux executables do not have a line ending that we could recognize we'll have to do it this way.
    - it will execute a chmod +x on the executable files so they really can be executed
    - update a json file in which it remembers the version, the zip file, and what exe files belong to it
    
The result is a clean tools directory with a json-File that acts as storage for all current release information as well as all up to date executable-versions of our tools. 
