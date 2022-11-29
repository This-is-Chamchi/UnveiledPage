using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PercentFoldObject : MonoBehaviour
{
    [SerializeField] private Vector3 startVector;
    [SerializeField] private Vector3 endVector;

    [SerializeField] private bool canSee;
    [SerializeField] private float percent;


    private void Start()
    {
        gameObject.SetActive(canSee);
    }

    public void SetSee(bool value)
    {
        gameObject.SetActive(canSee = value);
    }

    public void SeRotate(float value)
    {
        var v = value / percent;        
        transform.localRotation = Quaternion.Slerp(Quaternion.Euler(startVector), Quaternion.Euler(endVector), v);
    }

}
