using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HumanMatch_comfort : MonoBehaviour
{
    // Start is called before the first frame update
    private float time;
    private bool onetime;
    private GameObject Player;
    private GameObject Anna;
    private GameObject FlozenScreen;
    public bool deleteOn;
    
    
    void Start()
    {
        deleteOn = false;
        FlozenScreen = GameObject.FindWithTag("FrozenScreen");
        onetime = false;
        time = -1;
        gameObject.GetComponent<Renderer>().sharedMaterial.SetFloat("_Dissolve_Value", -1);
        Player = GameObject.FindWithTag("Player");
        Anna = GameObject.FindWithTag("Anna");
    }

    // Update is called once per frame
    void Update()
    {
        time += Time.deltaTime;

        if(time < 1)
        {
            gameObject.GetComponent<Renderer>().sharedMaterial.SetFloat("_Dissolve_Value", time);
        }
        else if(time > 1 && time < 5)
        {

        }
        else if(time > 5)
        {
            if(deleteOn == false)
            {
                time = 5;
                gameObject.GetComponent<Renderer>().sharedMaterial.SetFloat("_Dissolve_Value", 5);
            }
            else
            {
                gameObject.GetComponent<Renderer>().sharedMaterial.SetFloat("_Dissolve_Value", 6 - time);
                if (gameObject.GetComponent<Renderer>().sharedMaterial.GetFloat("_Dissolve_Value") < -1)
                {
                    Destroy(this.gameObject);
                }
            }

        }

        if(Anna.GetComponent<Anna>().AnnaPhase == 2 && onetime == false)
        {
            deleteOn = true;
            time = 5;
            onetime = true;
        }

    }

    public void Delete()
    {

    }
    private void OnTriggerEnter(Collider col)
    {

        if (col.tag == "Player")
        {
            Debug.Log("보호구역 들어감");
            FlozenScreen.GetComponent<FlozenScreen>().Clear(true);
        }

    }

    private void OnTriggerExit(Collider col)
    {
        if (col.tag == "Player")
        {
            Debug.Log("보호구역 들어감");
            FlozenScreen.GetComponent<FlozenScreen>().Clear(false);
        }

    }

    public void deleteMatch()
    {
        time = 5;
    }

}
