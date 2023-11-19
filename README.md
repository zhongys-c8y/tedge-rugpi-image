# thin-edge.io image using rugpi

The repository can be used to build custom Raspberry Pi images with thin-edge.io and rugpi (for firmware updates) pre-installed.

**Compatible devices**

* Raspberry Pi 4
* Raspberry Pi 5

## Building the image

To run the build tasks, install [just](https://just.systems/man/en/chapter_5.html).

1. Create the image (including downloading the supported base Raspberry Pi image) using:

    ```sh
    just build-all
    ```

2. Using the path to the image shown in the console to flash the image to the Raspberry Pi.

For further information, checkout the [Rugpi quick start guide](https://oss.silitics.com/rugpi/docs/getting-started).
