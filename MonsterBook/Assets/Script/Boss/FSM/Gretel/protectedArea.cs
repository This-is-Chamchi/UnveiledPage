using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class protectedArea : MonoBehaviour, IEntity
{
    private Transform HanselPos;
    private GameObject _Gretel;
    public void OnDamage(int damage, Vector3 pos)
    {
        _Gretel.GetComponent<Gretel>().OnDamage(damage,pos);
        Debug.LogError("그레텔 아프다");
    }

    void IEntity.OnRecovery(int heal)
    {
       
    }

    // Start is called before the first frame update
    void Start()
    {
        _Gretel = GameObject.FindWithTag("Gretel");
        HanselPos = GameObject.FindWithTag("Boss").transform;
        gameObject.transform.position = new Vector3(HanselPos.position.x, HanselPos.position.y+4.5f, HanselPos.position.z);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

  


}
