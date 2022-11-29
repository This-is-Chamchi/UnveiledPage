using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Boomerang : MonoBehaviour
{
    [SerializeField] private Transform parent;
    private AudioSource audioS;
    
    private int damage;
    public bool isPlay;
    private GameObject obj;
    private BoxCollider coll;

    [SerializeField] private float moveSpeed;
    [SerializeField] private float roateSpeed;
    [SerializeField] private Vector3 height;

    private Vector3 targetPos;
    private Vector3 centerPos;
    private Vector3 startPos;

    private GameObject objName;


    private void Awake()
    {
        coll = GetComponent<BoxCollider>();
        audioS = GetComponent<AudioSource>();

        obj = transform.GetChild(0).gameObject;
        obj.SetActive(false);
        coll.enabled = false;
    }

    public void SetDamage(int damage)
    {
        this.damage = damage;
    }

    public void Shot(Vector3 target, Vector3 start)
    {
        audioS.Play();
        startPos = start;
        transform.position = start;
        targetPos = target;
        centerPos = start + (target - start) / 2 + height;
        //objName = SoundManager.PlayVFXLoopSound("Fortune_Attack",transform);
        StartCoroutine(Routine());
    }

    private IEnumerator Routine()
    {
        isPlay = true;
        coll.enabled = true;
        obj.SetActive(true);

        var p1 = Vector3.zero;
        var p2 = Vector3.zero;
        var pos = Vector3.zero;
        var time = 0f;
        while (transform.position != targetPos)
        {
            transform.Rotate(Vector3.up * Time.deltaTime * roateSpeed, Space.Self);
            time += Time.deltaTime * moveSpeed;
            p1 = Vector3.Lerp(startPos, centerPos, time);
            p2 = Vector3.Lerp(centerPos, targetPos, time);
            pos = Vector3.Lerp(p1, p2, time);

            transform.position = pos;            
            yield return YieldInstructionCache.waitForFixedUpdate;
        }
        p1 = Vector3.zero;
        p2 = Vector3.zero;
        pos = Vector3.zero;
        time = 0f;
        startPos = parent.position + new Vector3(0, 1);
        centerPos = startPos + (targetPos - startPos) / 2 - new Vector3(0,0,3);
        while (transform.position != startPos)
        {
            startPos = parent.position + new Vector3(0,1);
            transform.Rotate(Vector3.up * Time.deltaTime * roateSpeed, Space.Self);
            time += Time.deltaTime * moveSpeed;
            p1 = Vector3.Lerp(targetPos, centerPos, time);
            p2 = Vector3.Lerp(centerPos, startPos, time);
            pos = Vector3.Lerp(p1, p2, time);

            transform.position = pos;
            
            yield return YieldInstructionCache.waitForFixedUpdate;
        }

        audioS.Stop();
        obj.SetActive(false);
        coll.enabled = false;
        isPlay = false;
        Destroy(objName);
        //SoundManager.StopVFXLoopSound(GetHashCode().ToString(), "Fortune_Attack");
    }

    private void OnDestroy()
    {
        //if (isPlay) SoundManager.StopVFXLoopSound(GetHashCode().ToString() ,"Fortune_Attack");
    }


    private void OnTriggerEnter(Collider other)
    {
        IEntity entity = other.GetComponent<IEntity>();

        if (entity != null) entity.OnDamage(damage, transform.position);
    }
}
