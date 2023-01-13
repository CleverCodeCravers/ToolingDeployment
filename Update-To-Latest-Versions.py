import argparse
import json
import os
import zipfile
import requests
import shutil
import platform


operating_system = platform.system()
cwd = os.getcwd()


def get_releases_from_api(releases):
    assets = []

    for asset in releases["assets"]:
        if operating_system == "Linux" and 'linux-x64' in asset['name']:
            assets.append(asset)
        if operating_system == "Windows" and 'win-x64' in asset['name']:
            assets.append(asset)
    return assets


def get_executables_for_matched_oeprating_system(repo_folder):
    executables = []

    for f in os.listdir(repo_folder):
        if operating_system == 'Windows' and f.endswith(".exe"):
            executables.append(f)
        if operating_system == 'Linux' and not f.endswith(".pdb") and not f.endswith(".json") and not f.endswith(".config"):
            executables.append(f)

    return executables


def download_latest_release(repo, target_dir):

    response = requests.get(
        f'https://api.github.com/repos/CleverCodeCravers/{repo}/releases/latest')
    release_info = response.json()

    if "message" in release_info:
        return

    version_file = os.path.join(target_dir, 'versions.json')
    if os.path.exists(version_file):
        with open(version_file) as f:
            versions = json.load(f)
            if repo in versions and versions[repo] == release_info['tag_name']:
                print(f'{repo} is already up to date')
                return

    assets = get_releases_from_api(release_info)

    if not assets:
        print(f'No assets found for {repo}')
        return

    for asset in assets:
        zip_file = os.path.join(cwd, asset['name'])
        repo_folder = os.path.join(cwd, zip_file.replace(".zip", ""))
        with open(zip_file, 'wb') as f:
            f.write(requests.get(asset['browser_download_url']).content)
        with zipfile.ZipFile(zip_file, 'r') as zf:
            os.mkdir(repo_folder)
            zf.extractall(repo_folder)
            os.remove(os.path.join(cwd, zip_file))

        executing_file = get_executables_for_matched_oeprating_system(
            repo_folder)

        if not executing_file:
            print(f'No exe files found in {zip_file}')
            return
        for exe in executing_file:
            os.rename(os.path.join(repo_folder, exe),
                      os.path.join(target_dir, exe))
            shutil.rmtree(repo_folder, ignore_errors=False, onerror=None)

    if not os.path.exists(version_file):
        versions = {}
    versions[repo] = release_info['tag_name']
    with open(version_file, 'w') as f:
        json.dump(versions, f)
    print(f'{repo} has been successfully updated')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-TargetDirectory', '--target_dir', required=True)
    args = parser.parse_args()
    target_dir = args.target_dir

    if not os.path.exists(target_dir):
        os.makedirs(target_dir)

    response = requests.get(
        'https://api.github.com/orgs/CleverCodeCravers/repos')

    if "message" in response.json():
        print(response.json()["message"])
        exit()

    for repo in response.json():
        download_latest_release(repo["name"], target_dir)
