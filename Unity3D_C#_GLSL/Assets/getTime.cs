using UnityEngine;
using System.Collections;

public class getTime : MonoBehaviour {
	
	int timeOfYear = 0;
	public int timeOfDay = 0;
    public float updateInterval = 1.0f;

    public GameObject clouds;

    // 360 / 18400
    float updateStep = 0.01956521739130434782608695652174f;

    // TimeOfDay-rotation values
    public Vector3 morning;
    public Vector3 day;
    public Vector3 evening;
    public Vector3 night;

    GameObject[] Trees;
    public Terrain terrainSummer;
    public Terrain terrainWinter;
    public Terrain terrainSpringFall;

    // VALUES FOR DEBUGGING
    //-- DEMOMODE
    public bool demoMode = true;
    public float demoCycleSpeed = 0.15f;

    //-- TIME OF YEAR/DAY OVERRIDE
    public bool overrideTime = false;
    public int overrideTimeOfYear = 1;
    public int overrideTimeOfDay = 1;
	
	void Start ()
    {
        // Disable all terrain renderers
        Trees = GameObject.FindGameObjectsWithTag("Tree");
        for (var i = 0; i < Trees.Length; i++)
        {
            Trees[i].transform.GetChild(0).gameObject.GetComponent<MeshRenderer>().enabled = false;
            Trees[i].transform.GetChild(1).gameObject.GetComponent<MeshRenderer>().enabled = false;
            Trees[i].transform.GetChild(2).gameObject.GetComponent<MeshRenderer>().enabled = false;
            Trees[i].transform.GetChild(3).gameObject.GetComponent<MeshRenderer>().enabled = false;
        }

        UpdateTime();
        if (overrideTime)
        {
            timeOfDay = overrideTimeOfDay;
            timeOfYear = overrideTimeOfYear;
        }

        SetRotation();
        SetTerrain();
        StartCoroutine("TimeUpdater");
    }

    void Update()
    {
        // DAY NIGHT-CYCLE FOR DEBUGGING / DEMOING PURPOSES
        if (demoMode)
        {
            transform.RotateAround(transform.position, new Vector3(0, 1, 1), demoCycleSpeed);
        }
    }

    IEnumerator TimeUpdater()
    {
        while (true)
        {
            // Day/night cycle is handled by directional light x- and y-axis rotations
            // "Sun" rotates a full 360 in 18400 seconds/updates
            // Update transform-rotation
            
            transform.RotateAround(transform.position, new Vector3(0, 1, 1), updateStep);
   
            // Lower light intensity when lower than horizon, prevents unintentional shadows at nights
            if (transform.rotation.eulerAngles.x > 300.0f && transform.rotation.eulerAngles.x < 350.0f)
            {
                GetComponent<Light>().intensity = 0.1f;
            }
            else
            {
                GetComponent<Light>().intensity = 1.0f;
            }

            yield return new WaitForSeconds(updateInterval);
        }
    }

    void UpdateTime()
    {
        // Get system month and get time of year
        int month = System.DateTime.Now.Month;
        if (month == 1 || month == 2 || month == 12) timeOfYear = 1;
        if (month == 3 || month == 4 || month == 5) timeOfYear = 2;
        if (month == 6 || month == 7 || month == 8) timeOfYear = 3;
        if (month == 9 || month == 10 || month == 11) timeOfYear = 4;

        // Get system hour (universal time) and current time of day in Joensuu
        int hour = System.DateTime.UtcNow.Hour;
        hour += 2;
        if (hour == 24)
        {
            hour = 0;
        }
        if (hour == 25)
        {
            hour = 1;
        }

        // Set time of day based on time of year
        SetTimeOfDay(hour);
    }

    void SetRotation()
    {
        // Set starting light-rotation based on time of day
        switch (timeOfDay)
        {
            case 1:
                transform.eulerAngles = morning;
                break;
            case 2:
                transform.eulerAngles = day;
                break;
            case 3:
                transform.eulerAngles = evening;
                break;
            case 4:
                transform.eulerAngles = night;
                break;
        }
    }

    void SetTimeOfDay(int hour)
    {
        // Sets time of day according to time of year

        // WINTER
        if (timeOfYear == 1)
        {
            if (hour <= 11 && hour >= 9) timeOfDay = 1;
            if (hour <= 16 && hour >= 12) timeOfDay = 2;
            if (hour <= 19 && hour >= 17) timeOfDay = 3;
            if (hour <= 8 && hour >= 20) timeOfDay = 4;
        }

        // SPRING OR FALL
        else if (timeOfYear == 2 || timeOfYear == 4)
        {
            if (hour <= 11 && hour >= 8) timeOfDay = 1;
            if (hour <= 17 && hour >= 11) timeOfDay = 2;
            if (hour <= 21 && hour >= 18) timeOfDay = 3;
            if (hour <= 7 && hour >= 22) timeOfDay = 4;
        }

        // SUMMER
        else if (timeOfYear == 3)
        {
            if (hour <= 11 && hour >= 7) timeOfDay = 1;
            if (hour <= 18 && hour >= 12) timeOfDay = 2;
            if (hour <= 23 && hour >= 19) timeOfDay = 3;
            if (hour <= 6 && hour >= 0) timeOfDay = 4;
        }
    }

    void SetTerrain()
    {
        // Sets terrain by time of year
        if (timeOfYear == 1)
        {
            for (var i = 0; i < Trees.Length; i++)
            {
                Trees[i].transform.GetChild(3).gameObject.GetComponent<MeshRenderer>().enabled = true;
            }
            terrainSummer.enabled = false;
            terrainWinter.enabled = true;
            terrainSpringFall.enabled = false;
            Instantiate(clouds);
            // GameObject instance = Instantiate(clouds);
            GameObject.Find("Snow").GetComponent<ParticleSystem>().Play();
        }

        if (timeOfYear == 2)
        {
            for (var i = 0; i < Trees.Length; i++)
            {
                Trees[i].transform.GetChild(1).gameObject.GetComponent<MeshRenderer>().enabled = true;
            }
            terrainSummer.enabled = false;
            terrainWinter.enabled = false;
            terrainSpringFall.enabled = true;
        }

        if (timeOfYear == 3)
        {
            for (var i = 0; i < Trees.Length; i++)
            {
                Trees[i].transform.GetChild(2).gameObject.GetComponent<MeshRenderer>().enabled = true;
            }
            terrainSummer.enabled = true;
            terrainWinter.enabled = false;
            terrainSpringFall.enabled = false;
        }

        if (timeOfYear == 4)
        {
            for (var i = 0; i < Trees.Length; i++)
            {
                Trees[i].transform.GetChild(0).gameObject.GetComponent<MeshRenderer>().enabled = true;
            }
            terrainSummer.enabled = false;
            terrainWinter.enabled = false;
            terrainSpringFall.enabled = true;
        }
    }

}

