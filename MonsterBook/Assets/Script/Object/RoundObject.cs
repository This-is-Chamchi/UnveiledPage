using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RoundObject : MonoBehaviour
{
    [SerializeField] private Transform[] childRound;

    [SerializeField] private float[] multiple;
    private Transform target;


    private void Awake()
    {
        target = GameObject.FindGameObjectWithTag("MainCamera").transform;

    }

    private void Update()
    {
        if (target.position.x >= childRound[0].position.x)
        {
            for (int i = 0; i < childRound.Length; i++)
            {
                childRound[i].LookAt(new Vector3(target.position.x, childRound[0].transform.position.y, -target.position.z * multiple[i]));
            }
        }
        else
        {
            for (int i = 0; i < childRound.Length; i++)
            {
                childRound[i].rotation = Quaternion.identity;
            }
        }

    }



}
