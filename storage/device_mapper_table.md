# General
```bash
start length mapping [mapping_parameters...]
```
In the first line of a Device Mapper table, the *start* parameter must equal 0. The *start + length* parameters on one line must equal the start on the next line. Which mapping parameters are specified in a line of the mapping table depends on which mapping type is specified on the line.
Sizes in the Device Mapper are always specified in sectors (512 bytes).
When a device is specified as a mapping parameter in the Device Mapper, it can be referenced by the device name in the filesystem (for example, /dev/hda) or by the major and minor numbers in the format *major:minor*. The major:minor format is preferred because it avoids pathname lookups.

The following subsections describe the format of the following mappings:
* linear
* striped
* mirror
