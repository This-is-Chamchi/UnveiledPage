using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoupRangePoint : MonoBehaviour
{
    // Start is called before the first frame update
    Transform playerTransform;
    void Start()
    {
        playerTransform = GameObject.FindWithTag("Player").transform;

        gameObject.transform.position = new Vector3(gameObject.transform.position.x, gameObject.transform.position.y ,playerTransform.position.z);


    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
