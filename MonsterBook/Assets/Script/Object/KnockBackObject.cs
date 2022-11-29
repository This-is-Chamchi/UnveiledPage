using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class KnockBackObject : MonoBehaviour
{
    [SerializeField] private float horPower;
    [SerializeField] private float verPoer;

    private void OnTriggerStay(Collider other)
    {
        IKnockBack knock = other.GetComponent<IKnockBack>();

        var dir = (new Vector3(other.transform.position.x, other.transform.position.y) - new Vector3(transform.position.x, other.transform.position.y)).normalized * horPower;
        //var up = Vector3.up * verPoer;

        if (knock != null) knock.KnockBack(dir + Vector3.up *verPoer);        
    }
}
