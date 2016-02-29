using UnityEngine;
using System.Collections;

public class spotScript : MonoBehaviour
{
    void OnTriggerEnter(Collider other)
    {
        if (other.tag == "notparked")
        {
            other.tag = "parked";
        }
    }
}