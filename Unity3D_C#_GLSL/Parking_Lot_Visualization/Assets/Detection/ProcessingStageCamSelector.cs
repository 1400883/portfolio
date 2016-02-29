/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
using UnityEngine;
using System.Collections;

public class ProcessingStageCamSelector : MonoBehaviour {

  public KeyCode keySourceImageCam = KeyCode.Keypad0;
  public KeyCode keyLumBriConGamCam = KeyCode.Keypad1;
  public KeyCode keyGaussianCam = KeyCode.Keypad2;
  public KeyCode keySobelCam = KeyCode.Keypad3;
  public KeyCode keyCornerpointCam = KeyCode.Keypad4;

  // For increased performance, the script will keep only the currently 
  // active processing cam (or main camera if selected) enabled at all 
  // times. An exception to this is the source image plane camera that 
  // must be on for edge detection to work. 

  // Index of the source image plane camera that's never to be disabled.
  const int sourceCamIndex = 0;

  GameObject canvas;
  KeyCode prevKey;
  Camera[] camArray;
  CamScript camScript;

  void Awake() {
    // Ensure the index of the cam container is the first 
    // among its siblings. Other scripts rely on this!
    transform.SetSiblingIndex(0);
    camScript = transform.parent.parent.GetComponent<CamScript>();
    canvas = GameObject.Find("Canvas");
  }

  // Use this for initialization
  void Start () {
    camArray = new Camera[transform.childCount];
    for (int iChild = 0; iChild < transform.childCount; ++iChild)
      camArray[iChild] = transform.GetChild(iChild).GetComponent<Camera>();
	}
	
	void Update () {
    if (IsCameraSelected())
    {
      // Activate processing camera views current source camera has been selected
      int camIndex = 0;
      if (Input.GetKeyDown(keySourceImageCam) && prevKey != keySourceImageCam)
      {
        ActivateCamera(camIndex); prevKey = keySourceImageCam;
      }
      ++camIndex;
      if (Input.GetKeyDown(keyLumBriConGamCam) && prevKey != keyLumBriConGamCam)
      {
        ActivateCamera(camIndex); prevKey = keyLumBriConGamCam;
      }
      ++camIndex;
      if (Input.GetKeyDown(keyGaussianCam) && prevKey != keyGaussianCam)
      {
        ActivateCamera(camIndex); prevKey = keyGaussianCam;
      }
      ++camIndex;
      if (Input.GetKeyDown(keySobelCam) && prevKey != keySobelCam)
      {
        ActivateCamera(camIndex); prevKey = keySobelCam;
      }
      ++camIndex;
      if (Input.GetKeyDown(keyCornerpointCam) && prevKey != keyCornerpointCam)
      {
        ActivateCamera(camIndex); prevKey = keyCornerpointCam;
      }
    }
  }

  void ActivateCamera(int camIndex) {
    // NOTE: Better adjust camera enable state than just depth. 
    // This has a major positive impact in the performance. However,
    // the source image camera BLITs the image to other processing 
    // stages, and must therefore remain enabled at all times.
    for (int iCam = 0; iCam < camArray.Length; ++iCam)
    {

      if (iCam != camIndex)
      {
        // Stop other processing cameras from displaying info in the screen.
        camArray[iCam].GetComponent<ShaderCamGUI>().SetCamInfoDisplayState(false);
        if (iCam != sourceCamIndex)
          // Never disable source image cam
          camArray[iCam].enabled = false;

        camArray[iCam].depth = -1;
      }
      else
      {
        // Activate info text display for the selected camera
        camArray[camIndex].GetComponent<ShaderCamGUI>().SetCamInfoDisplayState(true);
        camArray[camIndex].depth = 0;
        camArray[camIndex].enabled = true;

        // NOTE: multi-camera support requires setting info displays of 
        // processing camera components under other source cameras off as 
        // well. This prevents info display from previous processing camera 
        // from remaining visible on different source camera activation.
        // Init assignment jCam = 1 to skip main camera.
        for (int jCam = 1; jCam < camScript.sourceCameras.Length; ++jCam)
        {
          CamScript.SourceCam sc = camScript.sourceCameras[jCam];
          if (sc.transform != transform.parent)
            // EnableMainCamera() will do the job
            sc.transform.GetChild(0).
              GetComponent<ProcessingStageCamSelector>().DisableProcessingCameras();
        }
      }
    }
  }

  bool IsCameraSelected() {
    // Compare index of the camera container object among 
    // its siblings to the index of the currently selected camera.

    // camScript's array has the main camera in the first index (== 0).
    // Sibling index of the transform of the camera container gameobject 
    // under whose hierarchy this script belongs to always equals one less, 
    // so compensate that.
    return transform.parent.GetSiblingIndex() + 1 == 
      camScript.GetSelectedCameraIndex();
  }

  public void EnableMainCamera() {
    // Disable processing cameras
    DisableProcessingCameras();
    // Set canvas guide text visible in main camera view
    canvas.SetActive(true);
    // Reset previous key to source image key
    prevKey = keySourceImageCam;
  }

  public void EnableProcessingCameras() {
    // Enable the set of processing cameras. Initially 
    // default to the unprocessed source image camera.
    ActivateCamera(0);
    // Set canvas guide text invisible outside of main camera view
    canvas.SetActive(false);
  }

  public void DisableProcessingCameras() {
    // Use negative index as an override code 
    // that will disable processing stage cameras
    ActivateCamera(-1);
  }

  public void ResetPreviousKey() {
    prevKey = keySourceImageCam;
  }
}
