/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
using UnityEngine;
using UnityEditor;
using System.Collections;

[CustomEditor(typeof(CamScript))]
public class SourceCamSelector_EditorExtension : Editor {

  int numCameras;
  int defaultBaseKeyCode;

  void OnEnable() {
    // + 1, because main cam is added along with other parking lot cameras
    numCameras = GameObject.FindGameObjectsWithTag("SourceCam").Length + 1;
    defaultBaseKeyCode = 98; // F1
  }

  // Camera prefabs added to, removed from or swapped order in the scene
  // will update internally only once OnInspectorGUI() executes after
  // the modification. This happens when the Source Camera Controller
  // scene object is selected.
  
  public override void OnInspectorGUI() {
    serializedObject.Update();
    DrawDefaultInspector();
    
    CamScript cameraScript = ((CamScript)target);
    
    SerializedProperty sourceCameras = serializedObject.FindProperty("sourceCameras");
    sourceCameras.arraySize = numCameras;
    // Add data for all cameras in the scene in the inspector, using default hotkeys
    for (int iCam = 0; iCam < numCameras; ++iCam)
    {
      // Add camera transforms and hotkeys in the inspector
      SerializedProperty tCamera = 
        sourceCameras.GetArrayElementAtIndex(iCam).FindPropertyRelative("transform");
      SerializedProperty hotkey =
        sourceCameras.GetArrayElementAtIndex(iCam).FindPropertyRelative("hotkey");

      if (iCam == 0) {
        // Add the main camera first
        // Transform
        tCamera.objectReferenceValue = (Object)Camera.main.transform;
        // Hotkey
        if (hotkey.enumNames[hotkey.enumValueIndex] == "None")
          hotkey.enumValueIndex = defaultBaseKeyCode;
      }
      else {
        // Add other camera containers after the main camera
        // Transform
        tCamera.objectReferenceValue = (Object)cameraScript.transform.GetChild(iCam - 1);

        // Hotkey
        // If KeyCode.None, init with the base value (main camera hotkey)
        if (hotkey.enumValueIndex == 0)
          hotkey.enumValueIndex = defaultBaseKeyCode;

        // Keep increasing the hotkey index from Unity default (duplicated 
        // from an earlier entry) until a free key is found.
        bool isDuplicateHotkey;
        do {
          isDuplicateHotkey = false;

          for (int jCam = 0; jCam < iCam; ++jCam) {
            // Debug.Log(sourceCameras.GetArrayElementAtIndex(jCam).FindPropertyRelative("hotkey").enumValueIndex + ", " + hotkey.enumValueIndex);
            if (hotkey.enumValueIndex == sourceCameras.GetArrayElementAtIndex(jCam).
              FindPropertyRelative("hotkey").enumValueIndex) // 0 == KeyCode.None
            {
              isDuplicateHotkey = true;
              ++hotkey.enumValueIndex;
              break;
            }
          }
        } while (isDuplicateHotkey);
      }
    }
    serializedObject.ApplyModifiedProperties();
  }
}

