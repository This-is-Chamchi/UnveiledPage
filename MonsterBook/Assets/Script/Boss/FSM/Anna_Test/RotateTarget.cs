using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateTarget : MonoBehaviour
{
    public GameObject Target;
    // Start is called before the first frame update
    void Start()
    {
        //transform.RotateAround(Target.transform.position, Vector3.left, 50);
    }

    // Update is called once per frame
    void Update()
    {
        transform.RotateAround(Target.transform.position, Vector3.back, 1);
        transform.LookAt(Target.transform);
        transform.Rotate(Vector3.left, 90);

        
    }


}


