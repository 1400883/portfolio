using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class driveLineController : MonoBehaviour
{
    public float updateInterval = 0.1f;
    public Transform spawn1;
    public Transform carPrefab;
    public int numberOfSlots = 61;
    public float backSpeed = 0.03f;
    public bool nmoStart = false;
    public float distThreshold = 0.3f;
    public float rotateSpeed = 10.0f;

    //määrittää ajan jonka sisällä ohjelman käynnistyksestä autot spawnataan suoraan ruutuun
    public float timerLimit = 20.0f;

    //parkkipaikkojen boolean-kytkimet
    public static List<bool[]> rows = new List<bool[]>();
    List<GameObject[]> cars = new List<GameObject[]>();

    void Start()
    {
        //Alustetaan taulukot parkkipaikkojen määrää vastaaviksi
        //cars = new GameObject[numberOfSlots];
        //pcontroller = new bool[numberOfSlots];

        // Haetaan määritettyjen parkkiruutujen kokonaislukumäärä
        ImageSlotExtractor ise =
            (ImageSlotExtractor)Object.FindObjectOfType(typeof(ImageSlotExtractor));
        numberOfSlots = ise.GetTotalSlotCount();

        int rowcount = ise.GetRowCount();

        // init arrays
        for (int i = 0; i < rowcount; i++)
        {
            int slotCount = ise.GetSlotCount(i);

            //init slots in rows
            bool[] slots = new bool[slotCount];
            rows.Add(slots);

            //init cars in rows
            GameObject[] carsInRows = new GameObject[slotCount];
            cars.Add(carsInRows);
        }

        int rowIndex = 0;
        //Alustetaan parkkipaikat ja navmeshobstaclet tyhjiksi
        foreach (bool[] slots in rows)
        {
            for (int i = 0; i < slots.Length; i++)
            {
                slots[i] = false;
                cars[rowIndex][i] = null;
                setNMO(false, rowIndex, i);
            }
            rowIndex++;
        }
    }

    // Update is called once per frame
    void Update()
    {
        //spawnataan autot alussa suoraan ruutuihin käyttämällä ajastinta
        if (timerLimit > 1)
        {
            int rowIndex = 0;
            foreach (bool[] slots in rows)
            {
                for (int i = 0; i < slots.Length; i++)
                {
                    if (slots[i] == true && cars[rowIndex][i] == null)
                    {
                        Transform temp = GameObject.Find("Row_" + (rowIndex + 1)).transform.Find("Spot_" + (i + 1));
                        cars[rowIndex][i] = (Instantiate(carPrefab, temp.position, temp.rotation) as Transform).gameObject;
                    }
                    timerLimit -= Time.deltaTime;
                }
                rowIndex++;
            }
        }
        else
        {
            //laitetaan navmeshobstaclet päälle, ellei paikalle spawnattu alussa autoa, kutsutaan vain kerran.
            if (nmoStart == false)
            {
                int rowIndex = 0;
                foreach (bool[] slots in rows)
                {
                    for (int i = 0; i < slots.Length; i++)
                    {
                        if (!slots[i])
                        {
                            setNMO(true, rowIndex, i);
                        }
                    }
                    nmoStart = true;
                    rowIndex++;
                }
            }
            checkSpots();
        }
    }

    //spawnaillaan ja poistetaan autot sen mukaan onko pcontroller[i] tosi vai ei
    //paikalle 0 spawnataan auto nro 0 jne.
    void checkSpots()
    {
        int rowIndex = 0;
        foreach (bool[] slots in rows)
        {
            for (int i = 0; i < slots.Length; i++)
            {
                Transform temp = GameObject.Find("Row_" + (rowIndex + 1)).transform.Find("Spot_" + (i + 1));
                if (slots[i] == true)
                {
                    activate(rowIndex, i, temp);
                }
                else if (slots[i] == false)
                {
                    deactivate(rowIndex, i , temp);
                }
            }
            rowIndex++;
        }
    }


    //Spawnataan auto, lisätään se tauluun ja siirretään parkkipaikalle
    public void activate(int row, int slot, Transform parkkipaikka)
    {
        setNMO(false, row, slot);
        if (cars[row][slot] == null)
        {
            cars[row][slot] = (Instantiate(carPrefab, spawn1.transform.position, Quaternion.identity) as Transform).gameObject;
        }
        NavMeshAgent agent = cars[row][slot].gameObject.GetComponent<NavMeshAgent>();
        agent.SetDestination(parkkipaikka.transform.position);
        if (Vector3.Distance(cars[row][slot].gameObject.transform.position, parkkipaikka.position) < distThreshold)
        {
            cars[row][slot].gameObject.transform.rotation = Quaternion.RotateTowards(cars[row][slot].gameObject.transform.rotation, parkkipaikka.rotation, rotateSpeed * Time.deltaTime);
        }
    }
    //siirretään auto pois parkkipaikalta ja asetetaan tagiksi kill
    public void deactivate(int row, int slot, Transform parkkipaikka)
    {
        if (cars[row][slot] != null)
        {
            NavMeshAgent agent = cars[row][slot].gameObject.GetComponent<NavMeshAgent>();
            agent.Stop();
            float dist = Vector3.Distance(parkkipaikka.position, cars[row][slot].gameObject.transform.position);
            if (dist < 2.5 && cars[row][slot].gameObject.tag != "kill")
            {
                cars[row][slot].gameObject.transform.Translate(Vector3.back * 0.020f);
                cars[row][slot].gameObject.transform.rotation = Quaternion.RotateTowards(
                cars[row][slot].gameObject.transform.rotation, spawn1.rotation, 25 * Time.deltaTime);
                cars[row][slot].gameObject.transform.Translate(Vector3.back * 0.020f);
            }
            else
            {
                cars[row][slot].gameObject.tag = "kill";
                agent.updateRotation = true;
                agent.SetDestination(spawn1.position);
                agent.Resume();
                setNMO(true, row, slot);
            }
        }
    }

    void setNMO(bool nmoSwitch, int row, int slot)
    {
        GameObject temp = GameObject.Find("Row_" + (row + 1)).transform.Find("Spot_" + (slot + 1)).gameObject;
        NavMeshObstacle nmo = temp.GetComponent<NavMeshObstacle>();
        nmo.enabled = nmoSwitch;
    }

    //jos auton tag on kill, tuhotaan auto sen osuessa spawniin
    void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "kill")
        {
            Destroy(other.gameObject);
        }
    }
}
