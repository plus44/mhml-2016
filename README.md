# Mobile Healthcare and Machine Learning 2016

##### Mihnea Rusu, Periklis Korkontzelos, Nathan Warner, Arda Can Ertay, Shawn Zhou
##### {mr3313, pk1913, ace13, njw13, sz51112}@ic.ac.uk
##### *Imperial College London*

[![helmo logo](art/png/helmo-logo-lowercase.png "Helmo Logo")][youtube_link]
Video :video_camera: link: [Youtube][youtube_link]

[youtube_link]: https://www.youtube.com/watch?v=dQw4w9WgXcQ

Our project, targeted at urban cyclists :bike:, is about building a system based around a helmet that determines when the user has fallen. A helmet-mounted device containing an inertial measurement unit (IMU) communicates to an iOS smartphone, via Bluetooth, the user's motion over 6 axes, as the user is falling. This data is recorded by the app and synced to a database hosted on the cloud :cloud:. 

Users may view a list of their falls from within the app. Falls can be visualised as 3D animations using the recorded data. The Metal :metal: API was successfully used to enable 3D GPU rendering on the phone :iphone:.

## Contents

This repository is compose of the following directories:
	- **[app](app)** iOS app source code for both the device-side app that was shown in the demo and the actual app. Carthage dependencies are included, but ideally you should resync them
	- **[art](art)** Design files used for the project, in various formats
	- **[docs](docs)** Reports written for this project (including the individual reports)
	- **[eval](eval)** Evaluation survey handed out to the participants of our testing
	- **[hardware](hardware)** Firmware source code for the microcontrollers
	- **[server](server)** Server-side source code for the web service

### Quick links:
	- [Design Report](docs/helmo-design-report.pdf)
	- [Final Report](docs/helmo-final-report.pdf)