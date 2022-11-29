using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestructionObject : MonoBehaviour, IEntity
{
    private LineRenderer line;
    [SerializeField] private Transform rotationObject;
    [SerializeField] private Transform lineTarget;
    private bool isCut;


    private void Awake()
    {
        line = GetComponent<LineRenderer>();

        line.SetPosition(0, transform.position);
        line.SetPosition(1, lineTarget.position);
    }

    public void OnDamage(int damage, Vector3 pos)
    {
        if (!isCut) Cutting();
    }

    public void OnRecovery(int heal)
    {

    }

    private void Cutting()
    {
        isCut = true;

        line.enabled = false;
        StartCoroutine(Routine());
    }

    private IEnumerator Routine()
    {        
        while (rotationObject.rotation != Quaternion.Euler(Vector3.zero))
        {
            rotationObject.rotation = Quaternion.Slerp(rotationObject.rotation, Quaternion.Euler(Vector3.zero), Time.deltaTime * 4);

            yield return YieldInstructionCache.waitForFixedUpdate;
        }        
    }

}
