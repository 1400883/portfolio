/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
using UnityEngine;
using System.Collections;

public class InputImageController : MonoBehaviour {

  public bool useNetworkSource;
  public string networkAddress;
  public Texture[] stillImages;
  
  ImageSlotExtractor ise;

  Material sourceMaterial;
  WWW networkSource;
  KeyCode baseKey;
  KeyCode prevKey;

  public const int defaultNetworkImageWidth = 512;
  public const int defaultNetworkImageHeight = 256;

  // Use this for initialization
  void Awake () {
    ise = transform.parent.GetComponent<ImageSlotExtractor>();
    sourceMaterial = 
      transform.GetChild(1).GetChild(1).GetChild(0).GetComponent<Renderer>().material;
  }

  void Start() {

    if (useNetworkSource)
    {
      try
      {
        // Only allow network source if address is non-empty
        if (networkAddress != "")
        {
          // A delay between requesting a network image and
          // receiving image data response demands for a temporary
          // texture. Size doesn't really matter as long as there
          // is a texture of any size for other scripts expecting
          // a texture to be found to poll.
          sourceMaterial.mainTexture = new Texture2D(
            defaultNetworkImageWidth, 
            defaultNetworkImageHeight);

          // Start capturing images from a network feed. 
          // First image needs to be updated ASAP.
          StartCoroutine(DownloadAndApplyNetworkImage(0f));
        }
        else
          throw new System.Exception(
            "Network image source selected for " + name + " but no network address " +
            "provided. Falling back to using still images.");
      }
      catch (System.Exception e)
      {
        Debug.LogWarning(e.Message);
        useNetworkSource = false;
      }
    }

    if (!useNetworkSource) {
      try
      {
        if (stillImages.Length == 0)
          // Local image storage selected but none provided in the inspector
          throw new System.Exception(
            "Local image storage option selected for " + name + " but no " +
            "images provided by user.");
        else
          foreach (Texture t in stillImages)
            if (t == null)
            {
              // Local image storage selected but all 
              // elements in the array not assigned
              throw new System.Exception(
                "Local image storage option selected for " + name +
                "but all elements in the image array not provided.");
            }

        // User requested local image storage or falling back
        // from empty network image address error.
        // Try to apply first image from given local image array.
        sourceMaterial.mainTexture = stillImages[0];     
      }
      catch (System.Exception e)
      {
        Debug.LogError(e.Message);
      }
    }

    // Hard-coded hotkeys go up starting from numeric key 1
    baseKey = KeyCode.Alpha1;
  }
  
  public bool IsUsingNetworkImage() { return useNetworkSource; }

  IEnumerator DownloadAndApplyNetworkImage(float updatePeriod) {
    // NOTE: values can't be yielded in a try-catch structure's try block.
    
    // Update delay
    yield return new WaitForSeconds(updatePeriod);
    // Attempt image download
    networkSource = new WWW(networkAddress);
    // Make sure the download has finished before going on
    yield return networkSource;

    try
    {
      if (!System.String.IsNullOrEmpty(networkSource.error))
        throw new System.Exception(
          "Error downloading from given network source: " + 
          networkSource.error);
      // Download success => apply texture to source image plane
      sourceMaterial.mainTexture = networkSource.texture;
      // Initiate next download round
      StartCoroutine(DownloadAndApplyNetworkImage(ise.updateSeconds));
    }
    catch (System.Exception e)
    {
      Debug.LogWarning(e.Message);
    }
  }

  // Update is called once per frame
  void Update () {
    if (!useNetworkSource)
    {
      for (int iTex = 0; iTex < stillImages.Length; ++iTex)
      {
        // Select a locally stored image from given 
        // array based on pressed numeric key
        KeyCode keyCode = (KeyCode)((int)baseKey + iTex);
        if (Input.GetKeyDown(keyCode) && prevKey != keyCode)
        {
          sourceMaterial.mainTexture = stillImages[iTex];
          prevKey = keyCode;
          break;
        }
      }
    }
  }

  public Texture GetPrimaryTexture() {
    return stillImages.Length > 0 ? stillImages[0] : null;
  }
}
