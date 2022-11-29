using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Circle_Script : MonoBehaviour
{
    private float circleSizeTimer = 0;
    private float circle_IntensityTimer = 0;
    private GameObject _Anna;
    // Start is called before the first frame update
    void Start()
    {
        circleSizeTimer = 0;
        circle_IntensityTimer = 0;
        _Anna = GameObject.FindWithTag("Anna");
    }

    // Update is called once per frame
    void Update()
    {
        if (circleSizeTimer > 0.002f)
        {

        }
        else
        {
            circleSizeTimer += Time.deltaTime / (_Anna.GetComponent<Anna>().circleSizeSpeed) / 1000;
        }
        gameObject.transform.localScale = new Vector3(circleSizeTimer, circleSizeTimer, circleSizeTimer);


        if (circle_IntensityTimer > 200)
        {

        }
        else
        {
            circle_IntensityTimer += Time.deltaTime * _Anna.GetComponent<Anna>().circleIntensitySpeed;
        }
        gameObject.GetComponent<MeshRenderer>().material.SetFloat("_Color_Intensity", circle_IntensityTimer);
    }
}
