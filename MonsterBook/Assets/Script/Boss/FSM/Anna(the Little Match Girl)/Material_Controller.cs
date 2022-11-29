using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Material_Controller : MonoBehaviour
{
    public Material Anna_Pahse1_Material;
    public Material Anna_Pahse2_Material;
    private GameObject Anna;
    public GameObject Anna_Face;
    private float time;
    private float time2;
    private bool onetime;
    private bool onetime2;
    private float time3;

    // Start is called before the first frame update
    void Start()
    {
        Anna = GameObject.FindWithTag("Anna");
        time = -3;
        time2 = -3;
        onetime = false;
        onetime2 = false;
    }

    // Update is called once per frame
    void Update()
    {
        if (Anna.GetComponent<Anna>().AnnaPhase == 2 && Anna.GetComponent<Anna>().Anna_Frozen_Die == true)
        {
            time += Time.deltaTime * 3;
            gameObject.GetComponent<SkinnedMeshRenderer>().material.SetFloat("Foot_Ice_Boundary", time);
            if(gameObject.GetComponent<SkinnedMeshRenderer>().material.GetFloat("Foot_Ice_Boundary") > 2.5f)
            {
                time2 += Time.deltaTime*3;

                gameObject.GetComponent<SkinnedMeshRenderer>().material.SetFloat("Body_Ice_Boundary", time2);
                Anna_Face.GetComponent<SkinnedMeshRenderer>().material.SetFloat("Body_Ice_Boundary", time2);
                if(gameObject.GetComponent<SkinnedMeshRenderer>().material.GetFloat("Body_Ice_Boundary") > 2.5f && onetime2 == false)
                {
                    onetime2 = true;
                    GameManager.FadeEffect(true, 4, 0);
                    GameManager.PlayCutScene(1,4);
                    return;
                }
                else
                {
                    return;
                }
            }
        }

    }
}
