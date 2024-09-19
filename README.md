![Tella](docs/feature_image.png?raw=true "Tella")

## Table of Contents

1. [Overview](#overview)

2. [Why Tella?](#why-tella)

3. [Detailed list of features](#features)

4. [How to get Tella and start using it?](#use-tella)

5. [Tech & frameworks used](#tech-used)

6. [Contributing to the code](#contributing)

7. [Translating the app](#translating)

8. [Contact us](#contact)

## Overview <a id="overview"></a>

In challenging environments, with limited or no internet connectivity or in the face of repression, Tella is an app that makes it easier and safer to document human rights violations and collect data. Tella is available Android and iOS. 

More information about how to get Tella --including user guides-- can be found on our [documentation platform](https://docs.tella-app.org/).

| [![Encrypting](docs/encrypting.gif)](https://tella-app.org/features#encryption/) | [![Server Connections](docs/connections.gif)](https://tella-app.org/for-organizations) |
|:---:|:---:|:---:|
| Taking and encrypting a photo | Collecting data |



Tella:
- encrypts photo, video, and audio files in a separate gallery so it cannot be accessed from the phone's regular gallery or file explorer.
- allows users to quickly delete all files in Tella's encrypted Gallery.
- enables users working with a group or organization to collect and send data to a server without relying on third-party apps or servers.

## Why Tella? <a id="why-tella"></a>

Across the world, journalists and human rights defenders are facing increasing levels of physical repression, with mobile devices searched or seized at border crossings and airports, checkpoints, in the street, or in targeted raids. At the same time, digital surveillance and censorship threaten the flow of information out of repressive areas, particularly on violence, human rights abuse, or corruption.

Tella's goal is to protect at-risk individuals and groups--advocates, journalists, human rights defenders--from repressive surveillance, whether physical or digital. Tella aims to provide a highly usable solution, accessible to all with minimal or no training, to collect, safeguard, and communicate sensitive information in highly repressive environments.

Tella has three main objectives:

- Protecting users who engage in documentation from physical and digital repression
- Protecting the data they collect from censorship, tampering, interception, and destruction
- Empowering individuals and groups to easily, quickly, and effectively collect data and produce high quality documentation that can be used for research, advocacy, or transitional justice

Tella is used by:

- Activists, organizers and human rights defenders to safely document events in their communities, produce reliable and verifiable evidence, and store data encrypted on their mobile devices.
- Media, professional reporters and citizen journalists to store sensitive media files encrypted as they travel, particularly as they cross borders.
- Civil society professionals and humanitarian workers to conduct interviews and collect data in poorly connected environments or in conflict areas.
- Electoral observation and monitoring organizations to monitor elections from inside and outside polling stations in real time and expose electoral fraud.
- Research institutions and international organizations to conduct research, interviews or surveys in challenging environments, particularly in conflict areas.

You can read [user stories here](https://tella-app.org/user-stories).


## Detailed list of features <a id="features"></a>

A detailed list of features for both Tella Android and iOS can be found [on the documentation](https://tella-app.org/features).


## How to get Tella and start using it? <a id="use-tella"></a>

### Tella for iPhone
Tella for iOS can downloaded [from the App Store](https://apps.apple.com/us/app/tella-document-protect/id1598152580).

### Get started on Tella iOS
A get started guide for Tella iOS is available [here](https://tella-app.org/get-started-ios).


## Tech & frameworks used <a id="tech-used"></a>
- [Secure Enclave](https://support.apple.com/guide/security/secure-enclave-overview-sec59b0b31ff/web) for security.
- [SwiftUI](https://developer.apple.com/documentation/swiftui) for presenting views and interfaces
- [AVFoundation](https://developer.apple.com/documentation/avfoundation), and [QuickLook](https://developer.apple.com/documentation/quicklook) for previewing files in app.
- [Mantis](https://github.com/guoyingtao/Mantis) for [edit image feature](https://tella-app.org/features#edit-media). 
- [GoogleSignIn](https://github.com/google/GoogleSignIn-iOS) and [GoogleAPIClientForREST/Drive](https://github.com/google/google-api-objectivec-client-for-rest) to implement [google drive connection](https://tella-app.org/g-drive)
- [SQLCipher](https://github.com/sqlcipher/sqlcipher) for encrypted DataBase. 
- [NextcloudKit](https://github.com/nextcloud/NextcloudKit) a package added to implement [Nextcloud connection](https://tella-app.org/nexcloud).


## Contributing to the code <a id="contributing"></a>

**Step 1: Get familiar with Tella.** The best way is simply to download Tella play with it and try the different features, or [read our documentation here](https://docs.tella-app.org).

**Step 2: Find an issue to work on.** Please find an issue that you would like to take on and comment to assign yourself if no one else has done so already. [All issues with the label `good first issue`](https://github.com/Horizontal-org/Tella-iOS/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22) are good ways to get started. Also, feel free to ask questions in the issues, and we will get back to you ASAP!

**Step 3: Fork the repo** Click the "fork" button in the upper right of the Github repo page. A fork is a copy of the repository that allows you to freely explore & experiment without changing the original project. You can learn more about forking a repo [in this article](https://help.github.com/articles/fork-a-repo/).

**Step 4: Create a branch** Create a new branch for your issue from `develop` branch. You can name it anything, but we encourage you to use the format `XXX-brief-description-of-feature` where XXX is the issue number.

**Step 5: Code away!** Feel free to discuss any questions on the issues as needed, and we will get back to you! Don't forget to write some tests to verify your code. Commit your changes locally, using descriptive messages and please be sure to note the parts of the app that are affected by this commit.

**Step 6: Pushing your branch and creating a pull request** Push your branch up and create a pull request. Please indicate which issue your PR addresses in the title. 

## Translating the app <a id="translating"></a>

Tella is currently available in [17 languages](https://tella-app.org/translating-tella). We are always looking to translate Tella into more languages.

If you are interested in adding a new language, or if you noticed a mistake or a missing translation, you can join [follow our contributing guidelines](https://tella-app.org/translating-tella/#how-do-i-become-a-translator).



## Contact us <a id="contact"></a>
We love hearing from users, designers, and developers!

We host monthly [community meetings](https://tella-app.org/community-meetings) and we offer different ways to [contact-us](https://tella-app.org/contact-us).

If you have any question, ideas or suggestions on how we can improve or what new features we should add, or if you need support deploying Tella, don't hesitate to reach out!


