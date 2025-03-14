# thin-edge.io image using Rugpi for Omron PC

This repository is based on the [thin-edge.io image using Rugpi]('https://github.com/thin-edge/tedge-rugpi-image'). The goal is to build Alpine image with thin-edge.io installed using Rugpi. All the requirements should be fulfilled. 

## Omron's requirements 

- Alpine OS
- No apk packages with GPL-v3 license 
- Include packages: gptfdisk, hwdata, dmidecode, pcituils, logrotate, btop, openssh, openrc, sudo, sysklogd, openntpd 
- With thin-edge.io installed 
- Use their own tested secure boot process, GRUB is not allowed 
- Plus: with tedge-apk-plugin and tedge-container-plugin installed 

## TODO:

- Check if the folked "thin-edge.io image using Rugpi" still work with [v0.8 Rugix]('https://oss.silitics.com/rugix/docs/upgrading-from-v0.7')
- Add/change the layer(s) for Alpine 
- Create recipe(s) to install/uninstall apk packages 
- Create recipe(s) to install tedge-container-plugin and tedge-apk-plugin
- Configure Omron's bootloader as an [Unknown Target]('https://oss.silitics.com/rugix/docs/bakery/systems#targets')


------------
Original README: 
--------------

# thin-edge.io image using Rugpi

The repository can be used to build custom Raspberry Pi images with thin-edge.io and [Rugpi](https://oss.silitics.com/rugpi/) for robust OTA Operating System updates.

## Compatible devices

**Using u-boot**

* Raspberry PI 1B
* Raspberry PI 2B Rev 1.2
* Raspberry PI Zero
* Raspberry PI Zero 2 W
* Raspberry PI 3

**Using tryboot**

* Raspberry Pi 4
* Raspberry Pi 5


## Images

The following images are included in this repository.

|Image|Description|
|-------|-----------|
|rpi-tryboot|Image for Raspberry Pi 4 and 5 devices which use the tryboot bootloader|
|rpi-tryboot-containers|Image for Raspberry Pi 4 and 5 devices which use the tryboot bootloader and with docker pre-installed|
|rpi-tryboot-rpi4|Raspberry Pi 4 image which includes the firmware to enable tryboot bootloader|
|rpi-u-boot|Image for Raspberry Pi 2, 3, zero 2W|
|rpi-u-boot-containers|Image for Raspberry Pi 2, 3, zero 2W with docker pre-installed|
|rpi-u-boot-armhf|Image for Raspberry Pi 1 and zero|
|rpi-u-boot-armhf-containers|Image for Raspberry Pi 1 and zero with docker pre-installed|

## Building

### Building an image

To run the build tasks, install [just](https://just.systems/man/en/chapter_5.html).

1. Clone the repository

    ```sh
    git clone https://github.com/thin-edge/tedge-rugpi-image.git
    ```

2. Create a custom `.env` file which will be used to store secrets

    ```sh
    cp env.template .env
    ```

    The `.env` file will not be committed to the repo

3. Edit the `.env` file

    If your device does not have an ethernet adapter, or you the device to connect to a Wifi network for onboarding, then you will have to add the Wifi credentials to the `.env` file.

    ```sh
    SECRETS_WIFI_SSID=example
    SECRETS_WIFI_PASSWORD=yoursecurepassword
    SSH_KEYS_bootstrap="ssh-rsa xxxxxxx"
    ```

    **Note**

    The Wifi credentials only need to be included in the image that is flashed to the SD card. Subsequent images don't need to included the Wifi credentials, as the network connection configuration files are persisted across images.

    If an image has Wifi credentials baked in, then you should not make this image public, as it would expose your credentials! 

4. Create the image (including downloading the supported base Raspberry Pi image) using:

    ```sh
    just build-pi4
    ```

    Alternatively, you can use any of the image names defined in the `rugpi-bakery.toml` file, where the image name is part of the `images.*` key. For example, for `images.rpi-tryboot-containers`, the `IMAGE` name would be `rpi-tryboot`. You can then build the image using the following command:

    ```sh
    just IMAGE=rpi-tryboot-containers build
    ```

5. Using the path to the image shown in the console to flash the image to the Raspberry Pi.

6. Subsequent A/B updates can be done using Cumulocity IoT or the local Rugpi interface on (localhost:8088)

    **Notes**

    You can apply image updates via the device's localhost:8088 interface, however you will have to expand the `.xz` image file to a `.img` file.

For further information on Rugpi, checkout the [quick start guide](https://oss.silitics.com/rugpi/docs/getting-started).


### Building images including thin-edge.io main

To build an image with the latest pre-release version from the [main channel](https://thin-edge.github.io/thin-edge.io/contribute/package-hosting/#pre-releases), set the following environment variable in the `.env` file in your project:

```sh
# thin-edge.io install channel. Options: "main",  "release" (latest official release)
TEDGE_INSTALL_CHANNEL=main
```

### Building for your specific device type

The different image options can be confusing, so to help users a few device specific tasks were created to help you pick the correct image.

#### Raspberry Pi 1

```sh
just build-pi1
```

#### Raspberry Pi 2

```sh
just build-pi2
```

#### Raspberry Pi 3

```sh
just build-pi3
```

#### Raspberry Pi 4 / 400

```sh
just build-pi4
```

**Note**

All Raspberry Pi 4 and 400 don't support tryboot by default, and need their firmware updated before the `tryboot` image can be used.

You can build an image which also includes the firmware used to enable tryboot. Afterwards you can switch back to using an image without the firmware included in it.

```sh
just build-pi4-include-firmware
```

#### Raspberry Pi 5

```sh
just build-pi5
```

#### Raspberry Pi Zero

```sh
just build-pizero
```

#### Raspberry Pi Zero 2W

```sh
just build-pizero2w
```

## Project Tasks

### Publishing a new release

1. Ensure you have everything that you want to include in your image

2. Trigger a release by using the following task:

    ```
    just release
    ```

    Take note of the git tag which is created as you will need this later if you want to add the firmware to the Cumulocity IoT firmware repository

3. Wait for the Github action to complete

4. Edit the newly created release in the Github Releases section of the repository

5. Publish the release

**Optional: Public images to Cumulocity IoT**


You will need [go-c8y-cli](https://goc8ycli.netlify.app/) and [gh](https://cli.github.com/) tools for this!

1. In the console, using go-c8y-cli, set your session to the tenant where you want to upload the firmware to

    ```sh
    set-session mytenant
    ```

2. Assuming you are still in the project's root directory

    Using the release tag created in the previous step, run the following:

    ```sh
    just publish-external <TAG>
    ```

    Example

    ```sh
    just publish-external 20231206.0800
    ```

    This script will create firmware items (name and version) in Cumulocity IoT. The firmware versions will be just links to the external artifacts which are available from the Github Release artifacts.

3. Now you can select the firmware in Cumulocity IoT to deploy to your devices (assuming you have flashed the base image to the device first ;)!

## Add SSH and/or wifi to Github workflow

You can customize the images built by the Github workflow by creating a secret within Github.

1. Create a repository secret with the following settings

    **Name**
    
    ```sh
    IMAGE_CONFIG
    ```

    **Value**

    ```sh
    SSH_KEYS_bootstrap="ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx bootstrap"
    SSH_KEYS_seconduser="ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx myseconduser"
    ```

    Remove any lines which are not applicable to your build.

2. Build the workflow from Github using the UI (or creating a new git tag)
