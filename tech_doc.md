# About eCDynamicEntity coordinates

sample from *World_Damagezones.sec*:

````
["class eCDynamicEntity"] = {
    matrix1 = {
            0.832,       0.000,       0.554,       0.000, 
            0.000,       1.000,       0.000,       0.000, 
           -0.554,       0.000,       0.832,       0.000, 
       -91233.188,   42219.395, -260709.422,       1.000, },
    matrix2 = {
            0.832,       0.000,       0.554,       0.000, 
            0.000,       1.000,       0.000,       0.000, 
           -0.554,       0.000,       0.832,       0.000, 
       -91233.188,   42219.395, -260709.422,       1.000, },
    bb_min = { -97942.421, 36085.191, -266904.750 },
    bb_mid = { -84524.046, 48353.621, -254514.187 },
    bb_max = { -91233.234, 42219.406, -260709.468 },
    diameter = 11001.05859375,
    guid1 = "0F9ABCF2-412D-4530-9D4A-B6390ACB1E64",
...
        ["ShapeBox"] = {
            ["class eCWeatherZoneShapeBox"] = {
                prop = { -- off 0x00018F36, 3 entries
                    ["LocalOffset"] = { -0.0625, 0.01171875, -0.015625 },
                    ["InnerExtends"] = { 4577.278, 5134.214, 2729.217 },
                    ["OuterExtends"] = { 5577.278, 6134.214, 3729.217 }
...
````
![coord example](/docs/img/eCDynamicEntity_coord.png?raw=true "coord example")
