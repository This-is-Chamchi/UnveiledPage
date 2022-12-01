using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlozenScreen : MonoBehaviour
{
    private float time;
    public bool Phasetwo;
    public bool FlozenStart;
    private GameObject Player;
    public bool ClearScreen;

    // Start is called before the first frame update

    public void Clear(bool type)
    {
        ClearScreen = type;

    }
    void Start()
    {
        ClearScreen = false;
        Player = GameObject.FindWithTag("Player");
        time = 0;
        Phasetwo = false;
        FlozenStart = false;
        gameObject.GetComponent<Renderer>().sharedMaterial.SetFloat("_Frozen_Boundary", 1);
        gameObject.GetComponent<Renderer>().sharedMaterial.SetFloat("_Frozen_Control", -1);
    }

    // Update is called once per frame
    void Update()
    {
        if(ClearScreen == true)
        {
            var mat2 = gameObject.GetComponent<Renderer>().sharedMaterial.GetFloat("_Frozen_Control");
            if (mat2 > -1f)
            {
                gameObject.GetComponent<Renderer>().sharedMaterial.SetFloat("_Frozen_Control", mat2 - Time.deltaTime);
            }

            else
            {
                gameObject.GetComponent<Renderer>().sharedMaterial.SetFloat("_Frozen_Boundary", 0.5f);
            }

        }


        if (FlozenStart == true && ClearScreen == false)
        {
            var mat2 = gameObject.GetComponent<Renderer>().sharedMaterial.GetFloat("_Frozen_Control");
            if (mat2 < 1.0f)
            {
                gameObject.GetComponent<Renderer>().sharedMaterial.SetFloat("_Frozen_Control", mat2 + Time.deltaTime);
            }

            else
            {
                //gameObject.GetComponent<Renderer>().sharedMaterial.SetFloat("_Frozen_Control", 1);
                var mat = gameObject.GetComponent<Renderer>().sharedMaterial.GetFloat("_Frozen_Boundary");
                if (gameObject.GetComponent<Renderer>().sharedMaterial.GetFloat("_Frozen_Boundary") == 1)
                    return;
                gameObject.GetComponent<Renderer>().sharedMaterial.SetFloat("_Frozen_Boundary", mat + Time.deltaTime);

                if (mat > 2.5f)
                {
                    gameObject.GetComponent<Renderer>().sharedMaterial.SetFloat("_Frozen_Boundary", 2.5f);

                    time += Time.deltaTime;
                    if(time > 3.0f)
                    {
                        Debug.Log("눈보라 대미지" + time);
                        Player.GetComponent<PlayerController>().OnDamage(10,Vector3.zero);
                        time = 0;
                    }
                }
            }


        }


        if (Phasetwo == true)
        {
            time += Time.deltaTime;

            var mat = gameObject.GetComponent<Renderer>().sharedMaterial.GetFloat("_Frozen_Boundary");
            var con = gameObject.GetComponent<Renderer>().sharedMaterial.GetFloat("_Frozen_Control");


            if (mat <= 1)
            {
                gameObject.GetComponent<Renderer>().sharedMaterial.SetFloat("_Frozen_Control", con-Time.deltaTime);
            }
            else
            {
                gameObject.GetComponent<Renderer>().sharedMaterial.SetFloat("_Frozen_Control", 1);
                gameObject.GetComponent<Renderer>().sharedMaterial.SetFloat("_Frozen_Boundary", mat - Time.deltaTime);
            }
        }



    }
}
