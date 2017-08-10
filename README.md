# react-native-caffe2

### Bring deep learning to mobile in 2 minutes 📱🥂

![Image](./img.png?raw=true)

react-native-caffe2 is a library made in order to bring deep learning to mobile very fast. The main vision is to implement heavily used deep learning solution (image classification, style transfer, text generation, ..) with high-level methods in React Native to make possible for anyone to create fully fonctional deep learning applications for Android and iOS very fast.

## Important notes ⚠️

- The current version is only experimental
- No support for Android for technical reasons from React Native (NDK required for React Native is version 10, for Caffe2 is superior than version 13)
- Support ios simulator only (no real device), device support coming soon

## Getting started [iOS] 📱

`$ npm install react-native-caffe2 --save`

### - Mostly automatic installation

`$ react-native link react-native-caffe2`

### - Manual installation

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-caffe2` and add `RNCaffe2.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNCaffe2.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

### Additional requirements

Frameworks used have to be manually linked to your project.

1. In XCode, go to File option, click on `Add Files to`, pick `Copy items of needed` option
2. Go to `../node_modules/react-native-caffe2/ios/Frameworks/`
3. Add `opencv2.framework`
4. In project navigator, right click on Project, go to `Build Phases` ➜ `Link Binary With Libraries`
5. Add the following frameworks : `CoreMedia.framework` `AssetsLibrary.framework` `CoreVideo.framework`

## Usage 🚀

One function is currently implemented: `classifyImage`
The arguments are:

- `imageName` : Name of the image to classify
- `initModel` : protobuf file for initialization model
- `predictModel` : protobuf file for predicition model
- `classes` : Array of classes to for prediction
- `callback` : Callback method called with predicted class

Unfortunately, all files (protobuf, image) must be recognized from ios code. Therefore every asset has to be put in the xcode project. In order to add an asset to the xcode project, you simply have to add the file in from the XCode IDE.


`index.ios.js`

```javascript
import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View
} from 'react-native';
import RNCaffe2 from 'react-native-caffe2';


export default class toast extends Component {
  constructor(props) {
    super(props);
    this.state = {label: 'react-native-caffe2'};
  }

  render() {
    var json = require('./classes');

    RNCaffe2.classifyImage( 'dog.jpg',
                            'exec_net',
                            'predict_net',
                            json.classes,
                            (error, label) => {
      if (error) {
        console.error(error);
      } else {
        this.setState({label: label});

      }
    });

    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          {this.state.label}
        </Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
});


AppRegistry.registerComponent('appName', () => appName);
```


### Methods coming :

- Classify from camera
- Classify general file
- Raw prediction (provide tensor and get tensor)

## TODO 📝

- Add high-level methods
- Add support for Android
- Make the library less disk consuming
- Allow user to provide file path to method without putting the file in xcode assets
- Find a way to not have to do the Additional Requirement stuff