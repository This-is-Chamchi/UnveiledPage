using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class KnifeEffectPosition : MonoBehaviour
{
    // Start is called before the first frame update
    public GameObject Knife;
    public bool TraceTrigger;
    void Start()
    {
        TraceTrigger = true;
    }

    // Update is called once per frame
    void Update()
    {
        if (TraceTrigger == true)
        {
            gameObject.transform.position = new Vector3(Knife.transform.position.x, 0, 0);
        }
        else
        {
            return;
        }
    }
}
