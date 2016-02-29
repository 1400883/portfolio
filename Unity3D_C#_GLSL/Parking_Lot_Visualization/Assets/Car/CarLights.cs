using UnityEngine;
using System.Collections;

public class CarLights : MonoBehaviour {

    public Light front;
    public Light back;
    public bool autoControl = true;
    public float checkInterval = 0.5f;
    public float distanceThreshold = 0.7f;

    Color frontBaseColor;
    Color backBaseColor;
    Renderer[] lights;
    public Material matFrontLight;
    public Material matBackLight;
    public Material matFrontLightLit;
    public Material matBackLightLit;

    private Vector3 tmpPos;

	// Use this for initialization
	void Start () {
        // Get light renderers
        lights = gameObject.GetComponentsInChildren<Renderer>();

        if (autoControl)
        {
            tmpPos = transform.position;
            StartCoroutine("CheckForMovement");
        }
    }

    IEnumerator CheckForMovement()
    {
        while (true)
        {
            // Turn on lights if moving faster than threshold, or off if not moving enough
            if (Vector3.Distance(transform.position, tmpPos) > distanceThreshold)
            {
                // Turn on spot-lights
                front.enabled = true;
                back.enabled = true;


                // Change light material to lit
                foreach (Renderer light in lights)
                {
                    if (light.tag == "front")
                    {
                        light.material = matFrontLightLit;
                    }
                    else if (light.tag == "back")
                    {
                        light.material = matBackLightLit;
                    }
                }
            }
            else
            {
                front.enabled = false;
                back.enabled = false;


                // Change light material to unlit
                foreach (Renderer light in lights)
                {
                    if (light.tag == "front")
                    {
                        light.material = matFrontLight;
                    }
                    else if (light.tag == "back")
                    {
                        light.material = matBackLight;
                    }
                }
            }
            tmpPos = transform.position;
            yield return new WaitForSeconds(checkInterval);
        }
    }
}
