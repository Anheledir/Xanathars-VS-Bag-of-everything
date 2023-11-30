# Xanathar's Visual Studio Extension Pack of Everything

This repository contains a Visual Studio Extension Pack project with a collection of my essential extensions bundled together for convenience. This pack is designed to streamline the development environment setup in Visual Studio by installing a curated set of extensions.

## Structure

The project is structured as follows:

- `Properties/`: Contains project properties and settings.
- `BasePack.csproj`: The project file for the extension pack.
- `Extensions.vsext`: JSON file listing the extensions included in the pack.
- `source.extension.vsixmanifest`: Manifest file for the extension pack.
- `UpdateExtensions.ps1`: PowerShell script for updating the list of extensions easily.
- `Properties/AssemblyInfo.cs`: Contains assembly metadata.

## Using `UpdateExtensions.ps1`

The `UpdateExtensions.ps1` script is used to manage the extensions included in the extension pack. It allows you to view, select, and update the list of extensions dynamically.

### How to Run

1. Open PowerShell.
2. Navigate to the directory containing `UpdateExtensions.ps1`.
3. Run the script:
   ```powershell
   .\UpdateExtensions.ps1
   ```
4. Follow the on-screen prompts to select or deselect extensions.
5. The script updates the `Extensions.vsext` file based on your selections.

### Features

- Lists all installed Visual Studio extensions.
- Allows selection of extensions to include in the pack.
- Automatically updates the `Extensions.vsext` file.
- Preserves and allows updating of the extension pack's description and version.

## Contributing

Contributions to this extension pack are welcome. If you have suggestions for additional extensions or improvements, please open an issue or submit a pull request.
Only add extensions that you have personally tested and verified to work with the latest version of Visual Studio 2022, and that you believe are essential / useful for a broad range of users.

## License

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.

## Fun-Fact about the Project Name

The project's name draws its inspiration from the renowned Dungeons & Dragons sourcebook, "Xanathar's Guide to Everything" 🎲📚. Just as Xanathar's guide offers a wealth of new rules and options for D&D players, our extension pack aims to provide developers with a comprehensive set of tools and features for their coding journeys in Visual Studio.