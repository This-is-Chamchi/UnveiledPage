using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateRing : MonoBehaviour
{
    // Start is called before the first frame update
    public GameObject Match;
    public float Matchdir;
    public GameObject TargetCenter;

    void Start()
    {
        this.transform.position = TargetCenter.transform.position;

        Match.transform.position = new Vector3(Match.transform.position.x, Match.transform.position.y + Matchdir, Match.transform.position.z);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
