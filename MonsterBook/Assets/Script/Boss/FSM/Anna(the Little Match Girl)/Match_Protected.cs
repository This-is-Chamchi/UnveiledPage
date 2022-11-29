using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Match_Protected : MonoBehaviour
{
    // Start is called before the first frame update
    private float distance;
    private GameObject Anna;
    private float dir = -1;
    
    void Start()
    {
        Anna = GameObject.FindWithTag("Anna");
    }

    // Update is called once per frame
    void Update()
    {
        if(Anna.GetComponent<Anna>().AnnaPhase == 2)
        {
            if(Anna.GetComponent<Anna>().Match_distance > 2.0f)
            {
                dir = -1;
            }
            else if(Anna.GetComponent<Anna>().Match_distance < 1.0f)
            {
                dir = 1;
            }




            Anna.GetComponent<Anna>().Match_distance += Time.deltaTime * Anna.GetComponent<Anna>().ProtectAreaRoundSpeed * dir;

        }

        transform.localPosition = new Vector3(0.2f, Anna.GetComponent<Anna>().Match_distance, 0);

    }
}
