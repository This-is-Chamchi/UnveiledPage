using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatchRing : MonoBehaviour
{
    private float Angle = 0;
    public float speed;

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        Angle = speed * Time.deltaTime;
        transform.Rotate(new Vector3(0,0,-Angle));
        //transform.localRotation = Quaternion.Euler(0, 0, -Angle);
    }


}
