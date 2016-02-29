/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
using UnityEditor;
using UnityEngine;
using System.Collections;

[CustomPropertyDrawer(typeof(SlotData))]
public class SlotPropertyDrawer : PropertyDrawer {
  // Number of rows the user has selected in the inspector
  int numRows;
  // Number of slots for a row the user has selected in the inspector
  int numSlots;
  // Foldout control state booleans
  bool[] rowFoldoutState;
  bool[,] slotFoldoutState;
  // Custom inspector drawing dimension holder
  Rect newPosition;
  RowManager rm = new RowManager();

  // A detection area for one slot is a quadrilateral, fixed 4 corner points
  const int numAreaCornerpoints = 4;

  // Custom inspector property drawing
  public override void OnGUI(Rect position, SerializedProperty property, GUIContent label) {
    rm.Clear();
    // Get a copy of rect to work with. This contains new control insert position & dimensions.
    newPosition = position;
    newPosition.height = RowManager.thinRowHeight;
    // Get properties from inspector content class
    SerializedProperty numRowsProperty = property.FindPropertyRelative("numberOfRows");
    SerializedProperty rowsProperty = property.FindPropertyRelative("rows");

    // Total number of rows set in the inspector
    numRows = numRowsProperty.intValue;
    // Create a Row[] array of numRows element(s)
    if (rowsProperty.arraySize != numRows)
      rowsProperty.arraySize = numRows;
    // Create an array for row foldout controls in the inspector 
    if (rowFoldoutState == null || rowFoldoutState.Length < numRows)
      rowFoldoutState = new bool[numRows];

    ///////////////////////////
    // Start adding controls
    ///////////////////////////
    // Init row height
    // "Number of rows" label & slider
    EditorGUI.PropertyField(newPosition, numRowsProperty);
    // Extra empty lines
    AddRow(2, true);
    // If non-zero amount, add other controls
    if (numRows > 0) {
  
      // "Detection Area Properties" label
      EditorGUI.LabelField(newPosition, "Detection Area Properties:");
      
      // Controls for each parking slot row
      for (int i = 0; i < numRows; ++i)
      {
        // Get properties from the content class
        SerializedProperty numSlotsProperty = 
          rowsProperty.GetArrayElementAtIndex(i).FindPropertyRelative("numberOfSlots");
        SerializedProperty slotsProperty =
          rowsProperty.GetArrayElementAtIndex(i).FindPropertyRelative("slots");

        // Restrict foldout width or GUI won't allow 
        // clicking anything else in the same row
        newPosition.width = 40f;
        // "Row N" foldout
        AddRow();
        rowFoldoutState[i] = 
          EditorGUI.Foldout(newPosition, rowFoldoutState[i], "Row " + (i + 1), true);

        // Total number of slots, for the current row, set in the inspector
        numSlots = numSlotsProperty.intValue;
        // Create a Slot[] array of numSlots element(s)
        if (slotsProperty.arraySize != numSlots)
          slotsProperty.arraySize = numSlots;
        // Create an array for slot foldout controls in the inspector.
        // NOTE: This needs to be a 2D array, because each row has its own 
        // set of slots. Otherwise, folding/unfolding a slot N for a row 
        // will repeat the command for every slot N in all rows.
        // This method will reserve extra elements for slots (2nd dimension
        // will mirror the greatest individual slot count to all slots)
        // but meh, it's just RAM.
        if (slotFoldoutState == null || 
            slotFoldoutState.GetLength(0) < numRows ||
            slotFoldoutState.GetLength(1) < numSlots)
          slotFoldoutState = new bool[numRows, numSlots];

        newPosition.x = 70f;
        newPosition.width = position.width - 56f;
        // "Number of Slots" label & slider
        EditorGUI.PropertyField(newPosition, numSlotsProperty);
        // Only add Slot listing if non-zero slot count and uncovered foldout
        if (numSlots > 0 && rowFoldoutState[i]) {
          for (int j = 0; j < numSlots; ++j) {
            // Get properties from the content class
            SerializedProperty areaCornerpointsProperty = 
              slotsProperty.GetArrayElementAtIndex(j).FindPropertyRelative("areaCornerpoints");
            SerializedProperty pxThresholdProperty = 
              slotsProperty.GetArrayElementAtIndex(j).FindPropertyRelative("pxThresholdLevel");
            // Fixed number of corner points
            if (areaCornerpointsProperty.arraySize != numAreaCornerpoints)
              areaCornerpointsProperty.arraySize = numAreaCornerpoints;

            newPosition.x = 24f;
            // Restrict foldout width or GUI won't allow 
            // clicking anything else in the same row
            newPosition.width = 40f;
            AddRow();
            // "Slot N" foldouts for each slot under current row
            slotFoldoutState[i, j] = 
              EditorGUI.Foldout(newPosition, slotFoldoutState[i, j], "Slot " + (j + 1), true);

            newPosition.x = 70f;
            newPosition.width = position.width - 56f;
            // "Px Threshold Level" label & slider
            EditorGUI.PropertyField(newPosition, pxThresholdProperty);
            // Only add individual slot controls if uncovered foldout
            if (slotFoldoutState[i, j]) {
              AddRow();
              // "Area corner points:" label
              EditorGUI.LabelField(newPosition, "Area corner points:");
              // Corner point coordinates
              for (int k = 0; k < areaCornerpointsProperty.arraySize; ++k) {
                // Get a property from the content class
                SerializedProperty areaCornerpointXProperty = 
                  areaCornerpointsProperty.GetArrayElementAtIndex(k).
                    FindPropertyRelative("x");

                AddRow();
                newPosition.x = 80f;
                newPosition.width = position.width - 56f;
                // "Corner N" label
                EditorGUI.PrefixLabel(newPosition, new GUIContent("Corner " + (char)('A' + k)));
                // "X   Y" controls
                newPosition.x += 78f;
                newPosition.width = position.width - 144f;
                GUIContent[] guiContent = new GUIContent[2];
                // MultiPropertyField will get the X and an array's length - 1
                // worth of following SerializedProperties. GUIContent[2] will 
                // get both X and Y.
                EditorGUI.MultiPropertyField(newPosition, guiContent, areaCornerpointXProperty);
              }
            } // if (slotFoldoutState[i, j])
          } // for (int j = 0; j < numSlots; ++j)
        } // if (numSlots > 0 && rowFoldoutState[i])
        
        // Reset X back to default left indent
        newPosition.x = position.x;

      } // for (int i = 0; i < numRows; ++i)
    } // if (numRows > 0)
    property.serializedObject.ApplyModifiedProperties();
  }

  // Will move the entry position vertically down. A line change, that is.
  // A line change will have two options, a thinner and thicker one.
  void AddRow(int amount = 1, bool wantThinSized = false) {
    float requestedRowHeight;

    if (wantThinSized) {
      // Use less spaceous rows, normally for blank separator lines
      requestedRowHeight = RowManager.thinRowHeight;
      rm.AddThinRow(amount);
    }
    else {
      // Use taller rows, normally for editable value rows
      requestedRowHeight = RowManager.thickRowHeight;
      rm.AddThickRow(amount);
    }
    for (int i = 0; i < amount; ++i)
      newPosition.y += requestedRowHeight;
  }

  // Custom property holder area height calculation function. Unity will set 
  // script inspector height based on the value returned by this override method.
  public override float GetPropertyHeight(SerializedProperty property, GUIContent label) {
    float returnVal = rm.GetRowPixels();
    return returnVal;
  }
}

public class RowManager {
  // Thin & thick row pixel heights
  public const int thinRowHeight = 17; 
  public const int thickRowHeight = 20;
  // Hard-coded inits
  const int initThinRowValue = 1;
  const int initThickRowValue = 0;

  int thinRows;
  int thickRows;

  // Use previous calculated value as a fallback mechanism. 
  // Explained in more detail below.
  int previousRowPixels;

  public RowManager() {
    Clear(); 
    // Use some fixed initial value to prevent Unity from 
    // shrinking the inspector view on script recompilation
    previousRowPixels = 6 * thinRowHeight;
  }
  public void AddThinRow(int amount = 1) { thinRows += amount; }
  public void AddThickRow(int amount = 1) { thickRows += amount; }
  public float GetRowPixels() {
    // NOTE: GetPropertyHeight does this weirdness right after recompilation, 
    // where it will not let OnGUI execute prior, messing up the custom 
    // inspector view height. In such case, return something more sensible than
    // initial values to have the view expand vertically at least a bit.
    if (thinRows != initThinRowValue || thickRows != initThickRowValue)
      // OnGUI() has successfully executed -> return proper height dimensions
      previousRowPixels = thinRows * thinRowHeight + thickRows * thickRowHeight;

    // Additional thin row to separate Save / Restore buttons
    return (float)previousRowPixels + thinRowHeight / 2;
  }

  public void Clear() {
    thinRows = initThinRowValue;
    thickRows = initThickRowValue;
  }
}