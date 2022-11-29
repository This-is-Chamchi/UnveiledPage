using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;

public class DestroyObject : MonoBehaviour, IEntity, ICutOff
{
    enum Type
    {
        None,
        Vanish,
        Destroy,
    }

    [SerializeField] private Type type;
    [SerializeField] public int count;
    public int curHp;
    private Material material;
    private Collider coll;


    private void Awake()
    {
        coll = GetComponent<Collider>();
        curHp = (count - 1) * 10;
        material = GetComponent<MeshRenderer>().material;
        material = GetComponent<MeshRenderer>().material = Instantiate(material);
    }

    public void OnDamage(int damage, Vector3 pos)
    {
        curHp -= damage;
        if(curHp <= 0)
        {
            CutDamage();
        }
    }
    private void OnCollisionEnter(Collision collision)
    {
            if (collision.collider.CompareTag("Boss"))
            {
                gameObject.transform.position = new Vector3(100, 0, 0);
            }
    }
    public void OnRecovery(int heal)
    { 

    }

    public bool CheckCutOff()
    {
        return curHp <= 0;
    }

    public void CutDamage()
    {
        //coll.enabled = false;
        switch (type)
        {
            case Type.Vanish:
                StartCoroutine(VanishRoutine());
                break;
            case Type.Destroy:
                if(curHp <= 0)
                {
                    gameObject.transform.position = new Vector3(100,100,0);
                    //gameObject.SetActive(false);
                }
                break;
            case Type.None:
                break;
        }
    }

    private IEnumerator VanishRoutine()
    {        
        var color = material.color;
        while (color.a > 0)
        {
            color.a -= Time.deltaTime;
            material.color = color;            
            yield return YieldInstructionCache.waitForFixedUpdate;
        }
        gameObject.SetActive(false);
    }

}
