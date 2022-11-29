using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HanselSutnPoint : MonoBehaviour
{
    public GameObject Hansel;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        gameObject.transform.position = new Vector3(Hansel.transform.position.x, gameObject.transform.position.y, gameObject.transform.position.z);
    }
}
