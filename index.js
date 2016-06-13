'use strict';

var React = require('react-native');
var {NativeModules} = React;

var FIRStorage = NativeModules.RNFIRMessaging;

class FCM {

    static getFCMToken() {
        return FIRMessaging.getFCMToken();
    }

    static requestPermissions() {
        return FIRMessaging.requestPermissions();
    }

    static UploadFileToFirebase(){
        return FIRMessaging.UploadFileToFirebase(...arguments);
    }

    static getDimentionOfImage(){
      return FIRMessaging.getDimentionOfImage(...arguments);

    };

}


FCM.initialData = FIRStorage.initialData;
FCM.initialAction = FIRStorage.initialAction;

module.exports = FCM;
