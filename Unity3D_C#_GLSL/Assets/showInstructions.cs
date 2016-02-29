using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class showInstructions : MonoBehaviour
{

    public void Start() {
        GameObject.Find("Kaantuminen").GetComponent<Text>().enabled = false;

    }


    public void showText()
    {
        if (GameObject.Find("Kaantuminen").GetComponent<Text>().enabled == true)
        {
            GameObject.Find("Kaantuminen").GetComponent<Text>().enabled = false;
        }

        else if (GameObject.Find("Kaantuminen").GetComponent<Text>().enabled == false)
        {
            GameObject.Find("Kaantuminen").GetComponent<Text>().enabled = true;
        }
    }
}
