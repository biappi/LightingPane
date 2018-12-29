Lighting Pane
=============

This is my HomeKit light switch application I am using for my living room.

It is currently a personal project, so, for example, accessory configuration
or panel layout are hardcoded, but of course feel free to fork, contribute
or otherwise get get in touch.

To deploy the application ot the device, I am using the free personal
signing identity, so anyone should be able to run this project, if only
as an example.

Project Requirements
--------------------

The main reason I started this project, other than the tongue-in-cheeck
aesthetics, is to provide an effortless smart lighting control panel,
trying to have interactions that would not require more than one or two
touches of the panel.

My Installation
---------------

<img src="/Contrib/lights-on.jpeg" width="300px"> <img src="/Contrib/lights-off.jpeg" width="300px">

I control two lights with this panel, the main room illumination, using
two HomeKit lamps, and an accent / mood lamp. As I wish to still manually
control the two main lamps independently, I did not create an HomeKit
group, the main illumination sliders will send commands to both lamps.

The iPad I am currently using is running iOS 9.3, so that will be my
deployment target.

CoreLCARS.framework
-------------------

<img src="/Contrib/corelcars.png" width="600px">

Like many, I am a fan of Star Trek, and having to create a touch control
UI hanging off a wall (and having very passable design skills) I took
the opportunity to replicate the look of the show LCARS panel.

This project contains a small number of `IBDesignables` in a Cocoa Touch
framework used to implement the LCARS design language. It could be easily
lifted to its own project, but if the need will not arise, I prefer to
include the sources directly in this repository to ease software management.

CoreLCARS Requirements
----------------------

This framework is intended to be used for functional rather than artistic
interfaces. It should also try to respect Cocoa Touch conventions, and not
depend on any other third parties.

The LCARS interface is famously hard to use functionally, so the implementation
provided by this framework should err much more on the side of ergonomics
than its reference on the show.

For the same reason this framework should not mention any fictional tech,
events or characters.

