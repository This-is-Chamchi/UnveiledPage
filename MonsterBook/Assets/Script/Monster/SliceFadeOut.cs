using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SliceFadeOut : MonoBehaviour
{
    private bool FadeOutTime = false;
    private Material m_Material;
    private Color m_color;
    private bool Randompush = false;
    Rigidbody rigid;
    public float forcepower;
    private Transform _player;
    private bool forcedir;
    public bool SlicePowerDir;
    //

    void Start()
    {
        m_Material = gameObject.GetComponent<MeshRenderer>().material;
        this.gameObject.GetComponent<MeshRenderer>().material = Instantiate(m_Material);
        m_color = this.gameObject.GetComponent<MeshRenderer>().material.color;
        StartCoroutine("FadeOut");
        rigid = GetComponent<Rigidbody>();
        _player = GameObject.FindWithTag("Player").transform;

        if ((_player.position.x - transform.position.x) < 0)
        {
            forcedir = true;
        }
        else if((_player.position.x - transform.position.x) > 0)
        {
            forcedir = false;
        }

        pushSliceParts();
    }

    // Update is called once per frame
    void Update()
    {

        if (FadeOutTime == true)
        {
            m_color.a -= 0.01f;
            this.gameObject.GetComponent<MeshRenderer>().material.color = m_color;
            if (m_color.a < 0)
            {
                this.gameObject.SetActive(false);
            }
        }
       
    }
    void pushSliceParts()
    {
        if (SlicePowerDir == true)
        {
            if (forcedir == false)
            {
                rigid.AddForce(new Vector3(-1, 0, 0) * forcepower, ForceMode.Impulse);
            }
            else
            {
                rigid.AddForce(new Vector3(1, 0, 0) * forcepower , ForceMode.Impulse);
            }
        }
        else
        {
            rigid.AddForce(new Vector3(0, 10, 0), ForceMode.Impulse);
        }
    }
    IEnumerator FadeOut()
    {
        yield return new WaitForSeconds(2f);
        FadeOutTime = true;
    }
}
