using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SliceParts : MonoBehaviour
{
    public GameObject Monster;
    // Start is called before the first frame update
    void Start()
    {
        this.gameObject.transform.position = Monster.transform.position;
    }

    // Update is called once per frame
    void Update()
    {

    }

}
