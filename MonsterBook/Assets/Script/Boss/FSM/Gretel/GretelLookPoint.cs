using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GretelLookPoint : MonoBehaviour
{
    private Transform PlayerTransform;
    // Start is called before the first frame update
    void Start()
    {
        PlayerTransform = GameObject.FindWithTag("Player").transform;
    }

    // Update is called once per frame
    void Update()
    {
        gameObject.transform.position = 
            new Vector3(PlayerTransform.position.x, gameObject.transform.position.y, gameObject.transform.position.z);


    }
}
