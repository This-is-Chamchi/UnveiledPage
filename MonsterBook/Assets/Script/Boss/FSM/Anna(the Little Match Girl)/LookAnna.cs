using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LookAnna : MonoBehaviour
{
    // Start is called before the first frame update
    public Transform Anna;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        transform.LookAt(Anna);
    }
}
