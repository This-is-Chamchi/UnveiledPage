using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HumanMatch_Finish : MonoBehaviour ,IEntity
{
    public float time;
    public int curHp;
    private bool destroy;
    private bool destroying;
    private GameObject Player;
    private GameObject Anna;
    public float deleteTime;
    public GameObject Circle;
    public ParticleSystem HitEffect;
    public GameObject BoomEffect;

    void Start()
    {
        time = 0;
        destroy = false;
        destroying = false;
        Player = GameObject.FindWithTag("Player");
        Anna = GameObject.FindWithTag("Anna");
        BoomEffect = GameObject.FindWithTag("BoomEffect");

    }


    void Update()
    {
        
        time += Time.deltaTime;

        if (time < 1)
        {
            gameObject.GetComponent<Renderer>().material.SetFloat("_Dissolve_Value", time);
        }
        else if (time > 1 && time < deleteTime)
        {

        }
        else if (time > deleteTime)
        {
            gameObject.GetComponent<Renderer>().material.SetFloat("_Dissolve_Value", deleteTime - time);
            if (gameObject.GetComponent<Renderer>().material.GetFloat("_Dissolve_Value") < -1)
            {
                if (destroy == false)
                {
                    BoomEffect.GetComponent<ParticleSystem>().Play();
                    Player.GetComponent<PlayerController>().OnDamage(90, transform.position);    //Áï»ç 90µô
                }
                Destroy(this.gameObject);
            }
        }

    }

    public void OnDamage(int damage, Vector3 pos)
    {
        if(damage != 10)
        {
            return;
        }

        curHp -= damage;
        HitEffect.Play();
        if (curHp < 0)
            curHp = 0;

        if (curHp == 0)
        {
            if(destroying == false)
            {
                time = 20;
                Anna.GetComponent<Anna>().LastMatchClear = Anna.GetComponent<Anna>().LastMatchClear + 1;
                Debug.Log("ÀÎ°£¼º³É ÆÄ±«");
                Circle.SetActive(false);
                destroy = true;
                destroying = true;
            }
        }
    }

    public void OnRecovery(int heal)
    {
        
    }
}
