using System.Collections;
using System.Collections.Generic;
using System.Net.NetworkInformation;
using UnityEngine;
using UnityEngine.UIElements;

public class SkyStarController : MonoBehaviour
{
    [SerializeField] private Transform[] starObj;
    [SerializeField] private Transform target;

    private void FixedUpdate()
    {
        for (int i = 0; i < starObj.Length; i++)
        {
            if (starObj[i].position.x <= target.position.x - 92)
            {
                starObj[i].position = new Vector3(target.position.x+92, starObj[i].position.y + target.position.y, starObj[i].position.z);
            }
        }
    }

}
