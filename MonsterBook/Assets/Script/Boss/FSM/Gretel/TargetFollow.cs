using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TargetFollow : MonoBehaviour
{
    // Start is called before the first frame update
    public GameObject Target;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        gameObject.transform.position = new Vector3(Target.transform.position.x,
            Target.transform.position.y+10, Target.transform.position.z+10);
    }
}
