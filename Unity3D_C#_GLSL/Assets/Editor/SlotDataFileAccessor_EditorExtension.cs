/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
using UnityEngine;
using UnityEditor;
using System.Collections;
using System.IO;

[CustomEditor(typeof(SlotScript))]
public class SlotDataFileAccessor_EditorExtension : Editor {
  string subFolder = "SlotData";
  string filename;
  int fileLineNumber;
  bool isOverWriteOperation;

  public override void OnInspectorGUI() {
    filename = Application.dataPath + "/" + subFolder + "/" + 
        ((SlotScript)target).name + ".txt";

    serializedObject.Update();
    DrawDefaultInspector();
    // Add Save and Restore buttons
    if (GUILayout.Button("Save Data"))
    {
      try
      {
        Save();
        Debug.Log(
          "Slot data " + (isOverWriteOperation ? "overwritten to " : "saved to ") +
          filename);
      }
      catch (System.Exception e) {
        Debug.Log("Error writing to file: " + e.Message);
      }
    }
    else if (GUILayout.Button("Restore Data"))
    {
      if (File.Exists(filename))
      {
        try
        {
          Restore();
          Debug.Log("Slot data restored from " + filename);
        }
        catch (System.Exception e) {
          Debug.Log("Error reading from file: " + e.Message + ".\n" + 
            "Error source: near line " + Mathf.Max(fileLineNumber - 1, 1) +
            " in " + filename + ".");
        }
        // Apply settings retrieved from the file.
        // Data may not be complete if exception got thrown.
        serializedObject.ApplyModifiedProperties();
      }
      else
        Debug.Log("A data file could not be found in " + filename);
    }
  }

  void Save()
  {
    SlotScript ss = (SlotScript)target;
    // Create subfolder if it doesn't exist yet
    if (!Directory.Exists(subFolder))
      Directory.CreateDirectory(Application.dataPath + "/" + subFolder);

    isOverWriteOperation = File.Exists(filename);

    using (StreamWriter sw = new StreamWriter(filename))
    {
      for (int iRow = 0; iRow < ss.slotData.numberOfRows; ++iRow)
      {
        // Write row title
        sw.WriteLine("Row " + (iRow + 1));
        SlotData.Row row = ss.slotData.rows[iRow];
        for (int iSlot = 0; iSlot < row.numberOfSlots; ++iSlot)
        {
          // Write slot title
          sw.WriteLine("  Slot " + (iSlot + 1));
          SlotData.Slot slot = row.slots[iSlot];
          // Write pixel threshold level
          sw.WriteLine("    " + slot.pxThresholdLevel);
          foreach (SlotData.Cornerpoint cp in slot.areaCornerpoints)
          {
            // Write cornerpoint coordinates
            sw.WriteLine("    " + cp.x + " " + cp.y);
          }
        }
      } // for
    } // using
  }

  void Restore()
  {
    using (StreamReader sr = File.OpenText(filename))
    {
      // Serialized properties to make dynamic changes to inspector data
      //////////////////////////////////////////////////////////////////
      SerializedProperty serSlotData = serializedObject.FindProperty("slotData");
      
      SerializedProperty serNumRows = serSlotData.FindPropertyRelative("numberOfRows");
      SerializedProperty serRows = serSlotData.FindPropertyRelative("rows");

      SerializedProperty serSlots = null;
      SerializedProperty serNumSlots = null;

      SerializedProperty serCoords = null;
      SerializedProperty serCoordsX = null;
      SerializedProperty serCoordsY = null;

      SerializedProperty serElement = null;
      
      // Wipe existing slot data from the inspector
      serNumRows.intValue = 0;
      serRows.arraySize = 0;

      string line;
      int numCoords = 0;
      string[] coords = null;

      bool isFirstRowFound = false;
      bool isSlotFound = false;
      bool isThresholdFound = false;
      bool areAllCoordsFound = true;

      // Start filling inspector up with values from the file
      ////////////////////////////////////////////////////////

      fileLineNumber = 0;
      float thresholdFloat;
      while ((line = sr.ReadLine()) != null)
      {
        ++fileLineNumber;
        line = line.TrimStart(' ');
        // Row title
        if (line.StartsWith("Row")) {
          if (!areAllCoordsFound)
            // Latest slot coordinates were incomplete
            ThrowException("Missing coordinate data");

          // Add a row in the inspector
          serRows.arraySize = ++serNumRows.intValue;
          // Get slot data for the current row
          serElement = serRows.GetArrayElementAtIndex(serNumRows.intValue - 1);
          serNumSlots = serElement.FindPropertyRelative("numberOfSlots");
          serSlots = serElement.FindPropertyRelative("slots");
          
          // Init the number of slots for the current
          // row to rebuild data from scratch
          serNumSlots.intValue = 0;
          
          numCoords = 0;
          isFirstRowFound = true;
        }
        // Slot title
        else if (line.StartsWith("Slot")) {
          if (!isFirstRowFound)
            // Slot line without a preceding row line
            ThrowException("Missing row identifier");
          else if (!areAllCoordsFound)
            // Previous slot coordinates in the same row were incomplete
            ThrowException("Missing coordinate data");
          // Add a new slot under current row in the inspector
          serSlots.arraySize = ++serNumSlots.intValue;
          // Get current slot data
          serElement = serSlots.GetArrayElementAtIndex(serNumSlots.intValue - 1);

          numCoords = 0;
          isSlotFound = true;
          areAllCoordsFound = false;
          isThresholdFound = false;
        }
        // Px threshold level
        else if (System.Single.TryParse(line, out thresholdFloat) && 
                (line.StartsWith("0") || line.StartsWith("1")))
        {
          if (!isSlotFound)
            // A Slot line did not preceed threshold data
            ThrowException("Missing slot identifier");
          else if (isThresholdFound)
            // A correct amount of coordinates did not follow threshold data
            ThrowException("Missing coordinate data");
          // Get pixel threshold data for the current slot
          serElement.FindPropertyRelative("pxThresholdLevel").floatValue = thresholdFloat;
          
          isThresholdFound = true;
        }
        // Slot coordinates
        else
        {
          if (areAllCoordsFound)
            // All coords for the slot have already been found
            ThrowException("Too many coordinates in a slot");
          else if (!isThresholdFound)
            // Threshold data did not preceed coordinate data
            ThrowException("Missing threshold data");

          // Get coordinate array
          if (numCoords == 0) {
            serCoords = serElement.FindPropertyRelative("areaCornerpoints");
            serCoords.arraySize = 0;
          }
          
          // Add a new coordinate pair under current slot
          serCoords.arraySize = ++numCoords;
          // Split space-separated coordinates
          coords = line.Split(' ');
          // Get Nth coordinate pair element
          serElement = serCoords.GetArrayElementAtIndex(numCoords - 1);
          // Get X and Y coordinate properties
          serCoordsX = serElement.FindPropertyRelative("x");
          serCoordsY = serElement.FindPropertyRelative("y");
          // Write a cornerpoint coordinate pair for the current slot
          serCoordsX.intValue = System.Int32.Parse(coords[0]);
          serCoordsY.intValue = System.Int32.Parse(coords[1]);

          if (numCoords == 4) {
            // Full slot data retrieved
            areAllCoordsFound = true;
            isThresholdFound = false;
            isSlotFound = false;
          }
        } // else
      } // while
    } // using
  }

  void ThrowException(string message)
  {
    throw new System.Exception(message);
  }
}

/*
Save data file example structure:

Row 1
  Slot 1
    0.097
    97 145
    133 137
    142 152
    113 158
  Slot 2
    0.098
    228 125
    256 133
    242 139
    230 135
Row 2
  Slot 1
    0.058
    295 242
    407 256
    386 286
    269 269
Row 3
  Slot 1
    0.058
    78 104
    82 109
    97 107
    88 99
*/