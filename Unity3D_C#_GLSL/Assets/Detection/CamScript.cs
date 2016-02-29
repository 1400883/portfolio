/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
using UnityEngine;
using System.Collections;

[System.Serializable]
public class CamScript : MonoBehaviour {

  // Struct to hold data for all cameras in the scene
  // (including main cam) and their selection hotkeys.
  // Transform component is used to enable storing
  // parent object reference to each processing camera.
  [System.Serializable]
  public struct SourceCam {
    public Transform transform;
    public KeyCode hotkey;
  }

  // DOES contain the main camera in the first array element!
  public SourceCam[] sourceCameras;

  KeyCode prevKey;
  int selectedCameraIndex;

  void Start() {
    // Defaults to the main camera.
    selectedCameraIndex = 0;
    // Run once initially to disable post-processing view
    // cameras from hogging resources on playback start.
    DisableProcessingCameras();
  }

  void Update() {
    for (int iCam = 0; iCam < sourceCameras.Length; ++iCam)
      // Wait for a camera selection hotkey
      if (Input.GetKeyDown(sourceCameras[iCam].hotkey) && 
          prevKey != sourceCameras[iCam].hotkey)
      {
        if (iCam == 0)
        {
          // Activate main camera
          Camera.main.depth = 0;
          DisableProcessingCameras();
        }
        else
        {
          // Disable main camera
          Camera.main.depth = -1;
          // Activate requested processing camera 
          sourceCameras[iCam].transform.GetChild(0).
            GetComponent<ProcessingStageCamSelector>().EnableProcessingCameras();
          // Reset previous key maintenance variable in the processing camera
          // selector script attached to selected source camera container.
          // This ensures previously stored keypress is "released" in the 
          // context of the freshly selected source camera, allowing full 
          // access to all processing cameras right away.
          sourceCameras[iCam].transform.GetChild(0).
            GetComponent<ProcessingStageCamSelector>().ResetPreviousKey();
        }

        prevKey = sourceCameras[iCam].hotkey;
        selectedCameraIndex = iCam;
        break;
      }
  }

  void DisableProcessingCameras() {
    // Allocate memory for each processing cam (main cam excluded)
    SourceCam[] processingCameras = new SourceCam[sourceCameras.Length - 1];

    // Extract main cam, leaving an array of processing cams
    System.Array.Copy(sourceCameras, 1, processingCameras, 0, sourceCameras.Length - 1);
    // Calling EnableMainCamera() on each processing cam ProcessingStageCamSelector 
    // will take care of disabling processing cams, leaving just the main cam active
    foreach (SourceCam sc in processingCameras) {
      sc.transform.GetChild(0).
        GetComponent<ProcessingStageCamSelector>().EnableMainCamera();
    }
  }

  public int GetSelectedCameraIndex() {
    // 0 for the main camera, >= 1 for other camera containers added in the scene
    return selectedCameraIndex;
  }
}

